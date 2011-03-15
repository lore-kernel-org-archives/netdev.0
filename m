From: Michael Smith <msmith@cbnco.com>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Tue, 15 Mar 2011 19:21:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1103151913340.28997@juice.ott.cti.com>
References: <4D7E928C.1030707@cbnco.com> <20110314.151424.212690587.davem@davemloft.net>
 <4D7E9558.7030102@cbnco.com> <20110314.152704.98879085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:37894 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540Ab1COXVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 19:21:35 -0400
In-Reply-To: <20110314.152704.98879085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Mar 2011, David Miller wrote:

> > David Miller wrote:
> > 
> >> Existing arguments might be large enough to carry more than one piece
> >> of information :-)
> > 
> > If it's encoded into another argument, would there be more overhead
> > from bit-shifting it out than you'd save by losing an argument?
> 
> It sure will if it's the different between the argument being passed
> in a register vs. on the stack.

I have a patch to replace u32 mark with an sk_buff. The mark is in the 
sk_buff already, and so is the secpath field I need. Would that be 
acceptable? I can hold off until the merge window is over.

-extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
-                              struct net_device *dev, __be32 *spec_dst,
-                              u32 *itag, u32 mark);

+extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
+                              u8 tos, int oif, struct net_device *dev,
+                              __be32 *spec_dst, u32 *itag);

(dev is also usually the same as skb->dev, but not always...)

Mike
