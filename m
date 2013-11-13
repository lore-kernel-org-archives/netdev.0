From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 18:14:27 -0800
Message-ID: <1384308867.28458.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:52016 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757543Ab3KMCOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:14:30 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so7798035pbb.31
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 18:14:29 -0800 (PST)
In-Reply-To: <20131113012920.GA27897@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 09:29 +0800, Herbert Xu wrote:
> On Tue, Nov 12, 2013 at 05:13:43PM -0800, Eric Dumazet wrote:
> >
> > Note this pskb_trim() will reallocate/copy nskb head completely, since
> > nskb is a clone. (And increment page counts of frags, then eventually
> > decrement them)
> > 
> > I tested this patch one 'router', and it seems fine, although we consume
> > ~90% more cpu doing the skb_segment() than not doing it.
> 
> I presume this is on a NIC that produces completely linear packets?

Yes, I used one host with a Mellanox (mlx4 driver), as the bnx2x 'GRO'
is partially done by the hardware...


> I wonder what happens if we don't convert head_frag to frags and just
> use frag_lists like we used to?

Yep, but this needs quite invasive changes in the GSO stack in general ?

skb_segment() callers would need to know how many MSS are stuffed per
skb, instead of assuming its 1 MSS.
