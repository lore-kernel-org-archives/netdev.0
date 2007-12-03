From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Mon, 3 Dec 2007 22:39:35 +1100
Message-ID: <20071203113935.GA25124@gondor.apana.org.au>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4781 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752090AbXLCLj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 06:39:56 -0500
Content-Disposition: inline
In-Reply-To: <4753AE07.1040906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 03:19:35PM +0800, Wang Chen wrote:
> 
> System calls should be USER. So change the BH to USER for
> UDP*_INC_STATS_BH().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

I've rearragned it so that we the new INC_STATS call is USER in the
first patch.  Otherwise it's all in net-2.6.25 now.

BTW, thanks to Gerrit's note I took a look at the underlying code
for the _BH/_USER stuff.  It's in fact totally broken when PREEMPT
is on.  It relies on the fact that process-context kernel code does
not get preempted by other process-context kernel code or for that
matter migrate to other CPUs, neither of which is true with PREEMPT
on.

So we need to fix this, and whatever the fix is will probably render
the BH/USER distinction obsolete.

Any takers?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
