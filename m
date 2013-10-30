From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Wed, 30 Oct 2013 12:06:44 +0800
Message-ID: <20131030040644.GA2755@gondor.apana.org.au>
References: <20131028115552.GC4408@cpaasch-mac>
 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029144100.GA28046@gondor.apana.org.au>
 <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
 <20131030015002.GB1347@gondor.apana.org.au>
 <1383105785.4857.21.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59832 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:06:46 -0400
Content-Disposition: inline
In-Reply-To: <1383105785.4857.21.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:03:05PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-30 at 09:50 +0800, Herbert Xu wrote:
> > 
> > Indeed I missed this.  Which commit introduced this change?
> 
> This was mentioned in the changelog :
> 
> <quote>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> </quote>

Thanks.

In that case we should be able to segment these full-sized skbs
without linearising.  What we should do is iterate through
each frag_list entry and apply the usual GSO code to them.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
