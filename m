From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable and friendly ?
Date: Thu, 16 Aug 2007 20:41:58 +0800
Message-ID: <E1ILefm-00010m-00@gondolin.me.apana.org.au>
References: <20070816140914.de24335c.dada1@cosmosbay.com>
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3616 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755257AbXHPMmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 08:42:07 -0400
In-Reply-To: <20070816140914.de24335c.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> I am wondering how to really solve the problem. Could a workqueue be used here instead of a timer ?

I think so.

A mutex would separate the GC and dst_ifdown.  You'd take the
spin lock in the GC only to replace the garbage list with NULL.
You then drop the lock to process it.  Once it's done you take
the lock again and join it with whatever that's been added in
the mean time.  This is easy because you should already have
the tail after the GC process.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
