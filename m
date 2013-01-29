From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: When TOS is inherited, use configured TOS
 value for non-IP packets
Date: Tue, 29 Jan 2013 14:06:31 -0500 (EST)
Message-ID: <20130129.140631.1784920486633961681.davem@davemloft.net>
References: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab3A2TGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:06:33 -0500
In-Reply-To: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 27 Jan 2013 18:04:58 -0500

> A GRE tunnel can be configured so that outgoing tunnel packets inherit
> the value of the TOS field from the inner IP header. In doing so, when
> a non-IP packet is transmitted through the tunnel, the TOS field will
> always be set to 0.
> 
> Instead, the user should be able to configure a different TOS value as
> the fallback to use for non-IP packets. This is helpful when the non-IP
> packets are all control packets and should be handled by routers outside
> the tunnel as having Internet Control precedence. One example of this is
> the NHRP packets that control a DMVPN-compatible mGRE tunnel; they are
> encapsulated directly by GRE and do not contain an inner IP header.
> 
> Under the existing behavior, the IFLA_GRE_TOS parameter must be set to
> '1' for the TOS value to be inherited. Now, only the least significant
> bit of this parameter must be set to '1', and when a non-IP packet is
> sent through the tunnel, the upper 6 bits of this same parameter will be
> copied into the TOS field. (The ECN bits get masked off as before.)
> 
> This behavior is backwards-compatible with existing configurations and
> iproute2 versions.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Seems reasonable, applied.  Thanks.

I worry though about the case where tiph comes from skb->data rather
than the tunnel parameter block, can you describe why this new behavior
is OK in that situation too.
