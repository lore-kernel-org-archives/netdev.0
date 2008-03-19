From: Octavian Purdila <opurdila@ixiacom.com>
Subject: question regarding (AF_INET6, SOCK_RAW, x != IPPROTO_RAW) sockets
Date: Wed, 19 Mar 2008 16:19:08 +0200
Message-ID: <200803191619.08728.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3396 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753805AbYCST0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:26:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

In a previous post I was asking about the ipv6_chk_addr check done in 
datagram_send_ctl when using raw sockets with IPROTO_RAW. Remi pointed out 
that this case is not relevant since we need to construct the IPv6 header 
anyway.

What about when using IPV6 raw sockets with protocol != IPPROTO_RAW? In this 
case, it seems that the header is constructed by the networking stack, and if 
we want to change the source address we need to use IPV6_PKTINFO.

But datagram_send_ctl is checking in ipv6_chk_addr for the source address to 
be a previously assigned address in the system. Is this check necessary for 
IPv6 raw sockets? The same check does not seem to be present for IPv4. Also, 
disabling ipv6_chk_addr in datagram_send_ctl for IPv6 raw sockets seems to 
fix our problem. But is this approach the right one?

Thanks,
tavi
