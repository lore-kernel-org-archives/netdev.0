From: Wei Dong <weid@nanjing-fnst.com>
Subject: Re: MIB "ipInHdrErrors" error
Date: Mon, 12 Jun 2006 16:49:23 +0800
Message-ID: <1150102163.2974.9.camel@L-tech>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:44510 "EHLO localmail")
	by vger.kernel.org with ESMTP id S1751118AbWFLIqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 04:46:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-12 at 15:24 +0800, Wei Dong wrote:
> > Also, when kernel receives an IP packet and need to forward, but
> > TTL=1 or TTL=0, kernel just sends an ICMP packet to inform the
> > sender TTL count exceeded, and doesn't increase this counter.
> 
> This part of your change seems correct, please just resubmit
> this part.
The following is the latest patch for MIB ipIHdrErrors. 

diff -ruN old/net/ipv4/ip_forward.c new/net/ipv4/ip_forward.c
--- old/net/ipv4/ip_forward.c	2006-06-06 13:56:48.000000000 +0800
+++ new/net/ipv4/ip_forward.c	2006-06-12 15:11:04.000000000 +0800
@@ -120,6 +120,7 @@
 
 too_many_hops:
         /* Tell the sender its packet died... */
+        IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
         icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);

Signed-off-by: Weidong <weid@nanjing-fnst.com>



