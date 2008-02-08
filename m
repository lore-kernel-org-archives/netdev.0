From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET/IPv6] Race condition with flow_cache_genid?
Date: Sat, 09 Feb 2008 05:16:14 +1100
Message-ID: <E1JNXlm-0004pM-00@gondolin.me.apana.org.au>
References: <f73f7ab80802061036u64a56abnccafacf68f2ed717@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: kyle@moffetthome.net (Kyle Moffett)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53351 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758463AbYBHSQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 13:16:19 -0500
In-Reply-To: <f73f7ab80802061036u64a56abnccafacf68f2ed717@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kyle Moffett <kyle@moffetthome.net> wrote:
>
> Basically either there is some missing locking here or it does not
> need to be "atomic_t".  Judging from the way it *appears* to be used
> to check if cache entries are up-to-date with the latest changes in
> policy, I would guess the former.

You're right that it doesn't really have to be an atomic since
all the writers are from xfrm currently.  However, the fact that
it is atomic is used by the current code since sometimes they
increment the value without holding the xfrm policy lock.

Yes it is racy but that is fine for the purpose that this variable
serves.  All it does is to make sure that extant flow objects get
killed at some point after the increment.  There is absolutely no
requirement that the killing be immediate or synchronised.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
