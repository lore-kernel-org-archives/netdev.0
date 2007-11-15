From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Thu, 15 Nov 2007 15:37:25 +0800
Message-ID: <E1IsZHx-0006Kv-00@gondolin.me.apana.org.au>
References: <p73r6isc6ev.fsf@bingen.suse.de>
Cc: dada1@cosmosbay.com, davem@davemloft.net, netdev@vger.kernel.org
To: andi@firstfloor.org (Andi Kleen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3560 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755632AbXKOHh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 02:37:57 -0500
In-Reply-To: <p73r6isc6ev.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> wrote:
>
> A cheaper change might have been to just limit the number of buckets
> scanned.

Actually the whole point of moving it out to process context
is so that we don't have to worry about keeping track of the number
of buckets since deciding on how many buckets to process is black
magic.

IMHO preemption is the answer :) But failing that, a resched
is the next best thing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
