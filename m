From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Sun, 3 Feb 2008 10:35:30 +0100
Message-ID: <20080203093530.GA20908@one.firstfloor.org>
References: <20080131185328.GD4671@one.firstfloor.org> <E1JLRIM-0008FO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, shemminger@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46983 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936331AbYBCJAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 04:00:51 -0500
Content-Disposition: inline
In-Reply-To: <E1JLRIM-0008FO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2008 at 09:57:10AM +1100, Herbert Xu wrote:
> Andi Kleen <andi@firstfloor.org> wrote:
> >> Then change TBF to use skb_gso_segment?  Be careful, the fact that
> > 
> > That doesn't help because it wants to interleave packets
> > from different streams to get everything fair and smooth. The only 
> > good way to handle that is to split it up and the simplest way to do 
> > this is to just tell TCP to not do GSO in the first place.
> 
> Actually if we're going to do this I'd prefer you to call skb_gso_segment
> instead because that lets us at least bypass netfilter which is one of
> the key benefits of software GSO.

Ok. The only problem I see right now is that skb_segment() seems to overuse
GFP_ATOMIC which would make it unreliable, but that is something that can be 
fixed.

-Andi
