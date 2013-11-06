From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 07:05:41 -0800
Message-ID: <1383750341.4291.166.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106040717.GA15711@gondor.apana.org.au>
	 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106042858.GA15745@gondor.apana.org.au>
	 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106080425.GA17556@gondor.apana.org.au>
	 <20131106081638.GA17665@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:62313 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252Ab3KFPFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 10:05:43 -0500
Received: by mail-pd0-f174.google.com with SMTP id z10so10319569pdj.33
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 07:05:43 -0800 (PST)
In-Reply-To: <20131106081638.GA17665@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 16:16 +0800, Herbert Xu wrote:

> Instead of using perfectly sane 4K pages per frag to store guest to
> guest traffic, we now end up using 1.5K frags, which that's why you
> end up having to use the frag_list, WTF?

Sure, if your host has infinite amount of memory, we can remove all the
silly and expensive and bore some checks we added in the stack against
skb->truesize.

And yes, network stack will be faster.

But in real life, we have memory constraints.
