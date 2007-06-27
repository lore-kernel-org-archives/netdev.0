From: David Miller <davem@davemloft.net>
Subject: Re: resend [PATCH 1/5 2.6.21] UDP: Introduce UDP encapsulation
 type for L2TP
Date: Wed, 27 Jun 2007 00:15:26 -0700 (PDT)
Message-ID: <20070627.001526.35017006.davem@davemloft.net>
References: <200705261747.l4QHlOWO001715@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbXF0HPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 03:15:07 -0400
In-Reply-To: <200705261747.l4QHlOWO001715@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Sat, 26 May 2007 18:47:24 +0100

> This patch adds a new UDP_ENCAP_L2TPINUDP encapsulation type for UDP
> sockets. When a UDP socket's encap_type is UDP_ENCAP_L2TPINUDP, the
> skb is delivered to a function pointed to by udp_encap_l2tp_rcv. If
> the skb isn't wanted by L2TP, it returns >0, which causes it to be
> passed through to UDP. A funcptr is used for udp_encap_l2tp_rcv to 
> allow L2TP to be implemented as a kernel module.
> 
> Previously, the only user of UDP encap sockets was ESP, so when
> CONFIG_XFRM was not defined, some of the encap code was compiled 
> out. This patch changes that. As a result, udp_encap_rcv() will
> now do a little more work when CONFIG_XFRM is not defined. 
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> ---
> There are some magic numbers returned by udp_encap_rcv() that
> should perhaps now be made #defines. I chose not to do so in
> this patch.

I have no problem with the magic numbers in an initial version
of this stuff, but I do not like the function pointer.

It's error prone, invites mis-use, and will be difficult to safely
register/deregister properly.

Perhaps one good idea would be to store the encap handler in
the UDP socket info directly.  In this manner, the code which
sets up->encap_type can set the callback in the socket and
do appropriate locking and reference counting.
