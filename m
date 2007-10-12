From: David Miller <davem@davemloft.net>
Subject: Re: Non-linear SKBs
Date: Thu, 11 Oct 2007 17:00:24 -0700 (PDT)
Message-ID: <20071011.170024.38701852.davem@davemloft.net>
References: <470EA9AD.4020304@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: kristrev@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752852AbXJLAAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:00:21 -0400
In-Reply-To: <470EA9AD.4020304@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kristian Evensen <kristrev@ifi.uio.no>
Date: Fri, 12 Oct 2007 00:54:37 +0200

> I have developed a small patch for the TCP code in 2.6.19 and it works 
> flawlessly. A couple of days ago I decided to make it compatible with 
> 2.6.22.5 and have stumbled upon a problem I cannot solve.
> 
> In 2.6.19 it seems that all packets (at least the ones my patch work 
> with) are linear, while they are non-linear in 2.6.22.5. I have searched 
> through the code (focusing on tcp_sendmsg) to try to figure out what 
> happens, but can't find any differences that would explain this. Does 
> anyone know what might be the cause and if there is an easy way to 
> return to linear skbs (unless that is totally stupid)? I would also like 
> the benefits offered by the collapsing when retransmitting (which 
> requires number of fragments to be 0).

If the underlying device can do scatter-gather and checksumming,
the TCP code builds outgoing packets by copying user date into
full system pages, and then attaching those pages into the SKB.
The protocol headers sit under the skb->data linear area, and
the user data mostly sits in the user pages under
skb_shinfo(skb)->frags[]

This increases the density of data packed into the memory allocated
compared to using skb->data for it.  It also enormously simplifies
the logic necessary to support TSO.
