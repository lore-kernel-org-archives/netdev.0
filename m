From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Fri, 1 Apr 2016 08:46:27 +0800
Message-ID: <20160401004627.GA9367@gondor.apana.org.au>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com>
 <1459329252.2055.1.camel@sipsolutions.net>
 <20160330.123821.328761526754742195.davem@davemloft.net>
 <56FC0445.6010200@candelatech.com>
 <1459410405.4576.8.camel@sipsolutions.net>
 <20160331075015.GA27716@gondor.apana.org.au>
 <1459438199.4576.26.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35002 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659AbcDAAqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 20:46:39 -0400
Content-Disposition: inline
In-Reply-To: <1459438199.4576.26.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 05:29:59PM +0200, Johannes Berg wrote:
> 
> Does removing this completely disable the "-EEXIST" error? I can't say
> I fully understand the elasticity stuff in __rhashtable_insert_fast().

What EEXIST error are you talking about? The only one that can be
returned on insertion is if you're explicitly checking for dups
which clearly can't be the case for you.

If you're talking about the EEXIST error due to a rehash then it is
completely hidden from you by rhashtable_insert_rehash.

If you actually meant EBUSY then yes this should prevent it from
occurring, unless your chain-length exceeds 2^32.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
