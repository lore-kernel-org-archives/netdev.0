From: Octavian Purdila <opurdila@ixiacom.com>
Subject: mc_loop and multicast traffic with IPv6 over IPv4 tunnels
Date: Tue, 6 May 2008 23:58:25 +0300
Message-ID: <200805062358.25834.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1292 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759661AbYEFVO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 17:14:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

We are using a GRE tunnel module developed in house which can tunnel IPv6 
traffic over IPv4. The implementation is similar with what the upstream 
kernel does with GRE, IPIP or SIT tunnels, basically it stuffs the skb with 
the outer header and NF_HOOKs back to the stack. 

I've noticed that when using raw6 sockets on these tunnels, the 
IPV6_MULTICAST_LOOP setsockopt does not take effect, i.e. even if I set 
mc_loop to 0, I still get the send packets back when using a multicast 
address.

This problem seems to be caused by the fact that the when the skb is pushed 
through the tunnel it reaches the IPv4 layer which checks the mc_loop flag 
from the IPv4 part of the socket, which was not altered by the IPv6 
setsockopt. Modifying the IPv4's mc_loop as well in the IPv6's setsockopt 
seems to fix the problem.

I've looked over the upstream kernel GRE, IPIP and SIT tunnel code, and it 
seems that this case is not handled. I'll try to reproduce the problem with 
the upstream kernel as well, but in the meanwhile can somebody tell me if 
there is something obvious that I've missed?

Thanks,
tavi
