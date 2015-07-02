From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: Packet capturing performance
Date: Thu, 2 Jul 2015 14:02:12 +0800
Message-ID: <5594D3E4.5030803@windriver.com>
References: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Deniz Eren <denizlist@denizeren.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:54472 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbbGBGCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 02:02:18 -0400
In-Reply-To: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

You can use netfilter to mirror the packets to another nic. Then you can
capture these cloned patckets on this nic.

It can not affect the performance. Believe me, I made tests with it.

Zhu Yanjun

On 05/20/2015 09:13 PM, Deniz Eren wrote:
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
>
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
>
> Thanks in advance,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
