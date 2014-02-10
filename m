From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 13:23:31 +0100
Message-ID: <20140210122331.GA25153@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209025504.GB17395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55966 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453AbaBJMXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 07:23:36 -0500
Content-Disposition: inline
In-Reply-To: <20140209025504.GB17395@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > static void ip_gso_adjust_seglen(struct sk_buff *skb)
> > > {
> > >         unsigned int mtu;
> > > 
> > >         if (!skb_is_gso(skb))
> > >                 return;
> > > 
> > >         mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
> > >         skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);
> > > }
> > > 
> > > But this yields
> > > 
> > > [   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
> > 
> > Yep, lets CC Herbert Xu, as he 'owns' skb_segment()
> 
> IMHO we should just stop merging ~DF packets altogether, at least
> for TCP.

Eric, you added DF aggregation in db8caf3dbc77599dc90f4ea0a803cd1d97116f30
(gro: should aggregate frames without DF).

I guess you don't want to revert this commit?
Any other ideas?

skb_gso_segment() is already very complex, I don't want to add more code
to it.  And that seems unavoidable if we need to de-couple nr_frags and
gso_size.
