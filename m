From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 16:56:03 -0800
Message-ID: <1383785763.2878.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004704.GB28156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:61942 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab3KGA4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:56:05 -0500
Received: by mail-pb0-f53.google.com with SMTP id up7so288799pbc.40
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 16:56:04 -0800 (PST)
In-Reply-To: <20131107004704.GB28156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 08:47 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 04:15:21PM -0800, Eric Dumazet wrote:
> >
> > Here is the patch I came into (I tested it and it works very fine)
> 
> Thanks.  However, unless I'm missing something aren't you now
> copying every linear skb frag_list?  With the current code we
> just do a clone and add the headers.

No copy at all.

As explained, all RX skb are now backed to a page frag.  (see
skb->head_frag)

For safety I probably need to check this is safe.
