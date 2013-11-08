From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 11:59:49 +0800
Message-ID: <20131108035949.GA14325@gondor.apana.org.au>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <1383861288.9412.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49954 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756142Ab3KHEAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:00:06 -0500
Content-Disposition: inline
In-Reply-To: <1383861288.9412.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 01:54:48PM -0800, Eric Dumazet wrote:
>
> Hi Herbert
> 
> I believe I did this on my patch.

I actually quite like your patch for the pure iterative approach.

> Note that there is absolutely no requirement on how are the skb found in
> frag_list (their length is not a multiple of MSS)

OK I am thick and now I finally get what you're saying: virtio_net
as it stands does not produce the original GRO packet.  So my patch
is still broken with respect to virtio_net.  It won't crash anymore
but it'll just drop GRO/GSO packets which is probably worse.

> For the ease of discussion, once patched skb_segment() looks like :

However, I still have one reason for preferring my patch, it'll
be easier to prodce TSO packets with it.  Let me see if I can
fix up the arbitrary frag boundary issue without making it too
ugly.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
