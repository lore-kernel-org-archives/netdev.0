From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Mon, 23 Mar 2015 21:18:26 +1100
Message-ID: <20150323101826.GA13000@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
 <20150322115505.GD1185@casper.infradead.org>
 <20150322120415.GA5238@gondor.apana.org.au>
 <20150322123257.GI1185@casper.infradead.org>
 <20150322211241.GA7925@gondor.apana.org.au>
 <20150323095842.GF16023@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42509 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbCWKSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 06:18:54 -0400
Content-Disposition: inline
In-Reply-To: <20150323095842.GF16023@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 09:58:42AM +0000, Thomas Graf wrote:
>
> nft_hash sets key_len to set->klen and passes it to rhashtable_init().
> rhashtable_init() should then fall back to jhash() or jhash2() if no
> hashfn is provided. Why is the logic in rht_key_hashfn() different?
> Actually, in which case is ht->p.hashfn not set in rht_key_hashfn()?

jhash can be used in place of jhash2, the only difference is
that jhash is less optimised and uses unaligned loads.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
