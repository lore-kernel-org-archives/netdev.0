From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 12:28:27 +0800
Message-ID: <20131108042827.GB14577@gondor.apana.org.au>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
 <20131108021758.GA13467@gondor.apana.org.au>
 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108032208.GA14056@gondor.apana.org.au>
 <1383883594.9412.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108041016.GB14325@gondor.apana.org.au>
 <1383884683.9412.174.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39768 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753148Ab3KHE2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:28:34 -0500
Content-Disposition: inline
In-Reply-To: <1383884683.9412.174.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 08:24:43PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 12:10 +0800, Herbert Xu wrote:
> 
> > Well you still don't seem to be getting this: If you need it for
> > the host then you will need it even more for virt because the
> > network stack there is much longer.
> > 
> > So having it only available to the host without also giving it
> > to virt makes *zero* sense.
> 
> I am fine with this, but how can we know the packet is going to be
> delivered to virt instead of forwarded to ethernet ?

That's the crux of our disagreement :)

My preference is that if we can make it work at least as good
as before (if not better) in the forwarding case then we won't
need to care.

And so far I haven't seen any convincing argument why this cannot
be fixed in the forwarding case.

> Do we want the equivalent of 'IP early demux', done at GRO layer ? ;)

Won't help because the virt guest may end up forwarding the packet
anyway and you can't rely on it telling you that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
