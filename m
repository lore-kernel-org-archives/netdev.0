From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Mon, 3 Dec 2007 22:54:35 +1100
Message-ID: <20071203115435.GA4202@gondor.apana.org.au>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Ingo Molnar <mingo@elte.hu>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4986 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753633AbXLCLy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 06:54:56 -0500
Content-Disposition: inline
In-Reply-To: <20071203114912.GA4425@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 02:49:12PM +0300, Alexey Kuznetsov wrote:
> On Mon, Dec 03, 2007 at 10:39:35PM +1100, Herbert Xu wrote:
> > So we need to fix this, and whatever the fix is will probably render
> > the BH/USER distinction obsolete.
> 
> Hmm, I would think opposite. USER (or generic) is expensive variant,
> BH is lite. No?

Yes that would certainly be the obvious fix.  In other words, just use
smp_processor_id instead of the raw version.  I suppose the only issue
would be that disabling/enabling preemption isn't exactly cost-free and
we're going to be doing that for every single increment.

Hmm, wasn't someone else talking about a non-atomic version of atomic
ops lately (i.e., atomic with respect to the local CPU only)? Perhaps
this is the killer app for it :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
