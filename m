From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Tue, 12 Aug 2008 20:02:13 +0800
Message-ID: <20080812120213.GA22992@gondor.apana.org.au>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com> <200808121343.22892.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56457 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751271AbYHLMCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 08:02:38 -0400
Content-Disposition: inline
In-Reply-To: <200808121343.22892.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 01:43:22PM +0200, Wolfgang Walter wrote:
>
> * Works fine, machine is up since 61 minutes.

Thanks a lot for testing this Wolfgang!

> * Performance:
> 
> Routing performance over esp-tunnels seems unchanged here compared to 2.6.25
> (this was also the case with the "kernel_fpu_begin" patch).
> 
> tcrypt mode=200 shows exactly the same performance penalty compared to 2.6.25
> as the "kernel_fpu_begin" patch.

That's not surprising since tcrypt runs with BH off so it'll
do pretty much the same thing as before.  This also shows that
reading CR0 doesn't impose any extra overhead compared to what
was done in kernel_fpu_begin.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
