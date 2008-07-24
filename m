From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 23:01:16 +0800
Message-ID: <20080724150116.GA8692@gondor.apana.org.au>
References: <E1KM0DG-0001vY-00@gondolin.me.apana.org.au> <200807241634.31614.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51006 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750979AbYGXPBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 11:01:19 -0400
Content-Disposition: inline
In-Reply-To: <200807241634.31614.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 04:34:31PM +0300, Octavian Purdila wrote:
>
> > What about the other callers of copy_skb_header, like pskb_copy?
> 
> From what I understand, the shinfo remains shared, thus there is no need to do 
> the copy here.

No pskb_copy does a full copy on the head portion of the packet
which is where your cmsg is.

> > Also what about pskb_expand_head?
> >
> 
> I think this is only touching the skb header, not the shinfo. Thus we should 
> be safe?

But you're freeing the cmsg in skb_release_data which is called
by pskb_expand_head.  This can't possibly work.

> BTW: I have a dilemma with regard to fully copied skbs: should we copy the 
> cmsg queue as well, or should we just prune it in the copy? I don't see a 
> real usecase for doing the copy at this point, but since these is at core 
> level, maybe it is a good idea to be conservative and do the copying?

Do we need to make it so generic? If we do then can you please
come up with other uses for it too.  For example, find out what
existing fields can be better suited by storing them as a cmsg.
Only then can we design this properly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
