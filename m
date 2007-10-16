From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi poll
Date: Tue, 16 Oct 2007 14:06:51 +0800
Message-ID: <E1IhfZr-0002FE-00@gondolin.me.apana.org.au>
References: <1192513792.19073.23.camel@pasglop>
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	davem@davemloft.net, rdreier@cisco.com, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1044 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758202AbXJPGH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 02:07:27 -0400
In-Reply-To: <1192513792.19073.23.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> Note: I use msleep_interruptible(1); just like napi_disable(). However
> I'm not too happy that the "hot" loop that results of a pending signal
> here will spin without even a cpu_relax ... what do you guys think would
> be the best way to handle this ?

Well since the loop does not check signals at all, it should
just use msleep.

Granted the process will end up in the D state and contribute
to the load average.  But if this loop executes long enough
for that to be noticed then we've got bigger problems to worry
about.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
