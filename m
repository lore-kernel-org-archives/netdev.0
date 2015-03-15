From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink namespace/Merge
 jhash
Date: Sun, 15 Mar 2015 21:43:06 +1100
Message-ID: <20150315104306.GA21999@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <20150314025339.GA10585@gondor.apana.org.au>
 <20150315.013613.2034532005621627761.davem@davemloft.net>
 <20150315101004.GA21383@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49715 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbCOKnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:43:14 -0400
Content-Disposition: inline
In-Reply-To: <20150315101004.GA21383@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This series of patches deal with some niggly bits that nevertheless
need to be dealt with before we can move ahead.

I was trying to squeeze bucket_table->rehash in by downsizing
bucket_table->size, only to find that my spot had been taken
over by bucket_table->shift.  Patches 1-6 kills shift and makes
me feel better :)

One of the things I want to do is limit the chain length.  However,
certain users try to hash multiple objects with the same key.  This
would obviously defeat any attempt to control the maximum chain
length.  The only current offender using rhashtable is netlink and
it really has no excuse to do this at all.

Patches 7-10 resolves that problem.

Finally I saw that with every new rhashtable user we gained a copy
of jhash as it's an inline function so every indirect reference to
it results in another copy.  Patches 11-14 deal with this by making
jhash (or jhash2 when applicable) the function to use when the user
does not select a hash function.

PS I'd love to kill the indirect call on the hash but I think
you guys need something other than jhash for sockets.  Presumably
they are not exposed to untrusted parties.  But I really wonder
whether that is still the case given things like namespaces where
even root may be untrusted.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
