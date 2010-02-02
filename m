From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG]? xfrm: INFO: inconsistent lock state
Date: Tue, 2 Feb 2010 18:49:14 +1100
Message-ID: <20100202074914.GD11081@gondor.apana.org.au>
References: <4B66A670.70503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Yury Polyanskiy <polyanskiy@gmail.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55814 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755443Ab0BBHtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 02:49:20 -0500
Content-Disposition: inline
In-Reply-To: <4B66A670.70503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 01, 2010 at 06:01:20PM +0800, Wei Yongjun wrote:
> I got following lock INFO in my Fedora12 box uner 2.6.33-rc6.
> Is this a BUG?

Apparently.

This is introduced by

commit 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
Author: Yury Polyanskiy <polyanskiy@gmail.com>
Date:   Sun Nov 8 20:58:41 2009 -0800

    xfrm: SAD entries do not expire correctly after suspend-resume

To be honest I never liked that patch since the semantic change
makes sense for suspend-resume but is totally the wrong thing to
do when the system clock is stepped/changed.

Whether this is a real dead-lock depends on whether hrtimers
behave as real hard IRQs.  If they do then yes it can deadlock.

So my suggestion would be to just revert this change and consider
an alternative solution to the original suspend-resume problem.

My preference would be something that is triggered through power-
management as that would then allows us to differentiate between
the suspend-resume case and the clock change case.

It could even be triggered from user-space as it knows when an
resume occurs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
