From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable and friendly ?
Date: Thu, 16 Aug 2007 21:59:43 +0800
Message-ID: <E1ILft1-0001Db-00@gondolin.me.apana.org.au>
References: <20070816153619.2c699e21.dada1@cosmosbay.com>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4501 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758287AbXHPOPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 10:15:14 -0400
In-Reply-To: <20070816153619.2c699e21.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> Yes, I already did this (with the current softirq based timer model),
> but how can dst_dev_event() do its work, since the GC is using 
> a private list. (In my patch, time to GC process XXX.000 entries is about XX seconds.)
> 
> We would have to change dst_dev_event() to :
> - Signal to GC it has to stop as soon as possible.
> - Wait for GC be stoped (busy wait I suspect we cannot sleep in dst_dev_event() ? )

You can sleep in dst_dev_event so just use a mutex to separate
it from the GC.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
