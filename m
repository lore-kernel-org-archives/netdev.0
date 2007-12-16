From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Sun, 16 Dec 2007 10:36:21 +0800
Message-ID: <20071216023621.GB959@gondor.apana.org.au>
References: <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au> <20071215135851.GA29063@gondor.apana.org.au> <20071215184327.GA21434@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2260 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754647AbXLPCgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 21:36:54 -0500
Content-Disposition: inline
In-Reply-To: <20071215184327.GA21434@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 07:43:28PM +0100, Ingo Molnar wrote:
>
> we could perhaps introduce stat_smp_processor_id(), which signals that 
> the CPU id is used for statistical purposes and does not have to be 
> exact? In any case, your patch looks good too.

Unfortunately that doesn't work because we can then have two
CPUs trying to update the same counter which may corrupt it.

However, an optimisation is indeed possible with some work.
If we can get the address of the per-cpu counter against
some sort of a per-cpu base pointer, e.g., %gs on x86, then
we can do

	incq	%gs:(%rax)

where %rax would be the offset with %gs as the base.  This would
obviate the need for the CPU ID and therefore avoid disabling
preemption.

Hmm, wasn't Christoph working on something like that?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
