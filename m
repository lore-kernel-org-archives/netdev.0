From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] packet: make use of deferred TX queue
 flushing
Date: Mon, 25 Aug 2014 15:54:02 +0200
Message-ID: <20140825155402.2f2a03d7@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932406AbaHYNyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 09:54:07 -0400
In-Reply-To: <1408887738-7661-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Aug 2014 15:42:18 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> This adds a first use-case of deferred tail pointer flushing
> for AF_PACKET's TX_RING in QDISC_BYPASS mode.

Testing with trafgen.  I've updated patch 1/3 to NOT call mmiowb(),
during this testing, see why in my other post.

trafgen cmdline:
 trafgen --cpp  --dev eth5 --conf udp_example01.trafgen -V --cpus 1
 * Only use 1 CPU
 * default is mmap
 * default is QDISC_BYPASS mode

BASELINE(no-patches): trafgen QDISC_BYPASS and mmap:
 - tx:1562539 pps

With PACKET_FLUSH_THRESH=8, and QDISC_BYPASS and mmap:
 - tx:1683746 pps

Improvement:
 + 121207 pps
 - 46 ns (1/1562539*10^9)-(1/1683746*10^9)

This is a significant improvement! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Setup details:
--------------
Network overload testing setup according to:
 http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html

Trafgen input file:
 https://github.com/netoptimizer/network-testing/blob/master/trafgen/udp_example01.trafgen

Driver/NIC: ixgbe
CPU: E5-2695v2(ES)
