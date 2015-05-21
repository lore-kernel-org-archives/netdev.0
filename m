From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Packet capturing performance
Date: Thu, 21 May 2015 09:25:22 +0200
Message-ID: <20150521092522.3346be4e@redhat.com>
References: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: Deniz Eren <denizlist@denizeren.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbbEUHZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 03:25:27 -0400
In-Reply-To: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 May 2015 16:13:54 +0300
Deniz Eren <denizlist@denizeren.net> wrote:

> Hi,
> 
> I'm having problem with packet capturing performance on my linux server.
> 
> I am using Intel ixgbe 10g NIC with v3.19.1 version driver over Linux
> 3.15.9  based system. Naturally I can route 3.8Mpps packet from spoof
> (random source) addressed traffic.
> 
> Whenever I open netsniff-ng to listen interface to capture packets at
> silent mode, the capturing performance slows down at the same time to
> ~1.2Mpps levels. I have doing pps measurements by watching the changes
> at "/sys/class/net/<interface_name>/statistics/rx_packets" so the
> performance can not be affected the measurements (instead of tcpstat
> etc).

Did you try to use the recently add fanout feature of netsniff-ng?

 https://github.com/netsniff-ng/netsniff-ng/commit/f00d4d54f28c0

 
> My first theory was bpf is cause of this slowdown. When I try to
> analyze the reason of this bottleneck I see that the bpf affects the
> slow down ratio. When I narrow the filter to match 1/16 packet of
> traffic (for example: "src net 16.0.0.0/4" ), the capturing paket
> performance stay ~3.7Mpps. And I start 16 netsniff-ng process (each
> one process 1/16 part of entire traffic) with different filters the
> performance stays ~3.0Mpps and the union of the 16 filter equal to
> 0.0.0.0/0 (0.0.0.0/4 + 16.0.0.0/4 + 32.0.0.0/4 + ...  + 248.0.0.0/4 =
> 0.0.0.0/0) . In other words
> I think performance of network stack slow downs dramatically after a
> number of matching traffic packets with given bpf.
> 
> But after some investigation and some advice from more expert people
> the problem seems to be pf_packet sockets overhead. But I don't know
> exactly where is the bottleneck. Do you have any idea exactly where
> could be the bottleneck?
> 
> Since I am using netfilter a lot, kernel bypass is not an option for me.
> 
> To solve this problem I have two options for now:
> 
> - First one is experimenting socket fanout and adapting my tools to
> use socket fanout.
> - Second one is somehow similar, open more than one (ex: 16) socket
> MMAP'ed socket whose have different filters from each other to match
> with different part of the traffic at single netsniff_ng process. But
> this one is too hacky and requires user-space modifications.
> 
> But I want to ask is there a better solution to this problem? Am I
> missing a network tuning on linux or my ethernet device?


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
