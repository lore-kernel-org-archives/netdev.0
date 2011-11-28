From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 22:51:57 +0800
Message-ID: <20111128145157.GA17678@gondor.apana.org.au>
References: <20111123075433.GA7928@gondor.apana.org.au> <1322050976.2039.125.camel@mojatatu> <20111128130409.GB16828@gondor.apana.org.au> <0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56805 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab1K1OwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 09:52:16 -0500
Content-Disposition: inline
In-Reply-To: <0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 01:54:16PM +0000, Fischer, Anna wrote:
>
> Yes, I mentioned this months ago, and I am surprised this critical issue has never been picked up on and addressed. With a flaw like this there is no chance this component can be used in any serious virtualization deployment where different customers share the same physical server.
> 
> The path up to user-space needs to be designed in a multi-queue fashion, so that each vPort has its own queue up to user-space. Ideally those queues also need to be rate controlled in some form, so that no DoS is possible.

Actually, rereading the patch it would appear that the interface
does allow the use of multiple sockets at the user-space end.
Whether the user-space daemon actually does so is another matter
of course :)

There are other issues with the hash implementation.  For example,
there seems to be no limit on the number of collisions in each
bucket.  As the hash table growth code simply continues when it
fails to expand, this means that the number of collisions may
rise without bound.

At least this is each to fix, by using any one of our other
similar hash table implementations as an example.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
