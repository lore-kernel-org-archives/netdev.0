From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 04 Jan 2007 11:30:41 +1100
Message-ID: <E1H2GVF-0008GJ-00@gondolin.me.apana.org.au>
References: <OF68896635.077F2C1B-ON88257258.007F0BD8-88257258.007F8A72@us.ibm.com>
Cc: greearb@candelatech.com, jarkao2@o2.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3630 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932205AbXADAbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:31:16 -0500
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OF68896635.077F2C1B-ON88257258.007F0BD8-88257258.007F8A72@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
> 
> Ben,
>        Here's a patch that I think will fix it, assuming the receive is 
> on the
> same device as the initialization. Can you try this out?

Hi David:

Your patch makes sense on its own but I don't see the direct connection
to the soft lock-up.  Sure it prevents the code path in question from
triggering.  However, if we don't understand why it's locking up in the
first place then this may just be hiding it rather than fixing it.

In particular, a soft lockup means that we're doing so much work in
the softirq handlers that processes are not getting run.  So what is
it exactly here that's causing us to get stuck in the softirq handlers?
Is it because we're somehow getting stuck in a net rx loop?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
