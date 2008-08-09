From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 21:31:38 +0800
Message-ID: <20080809133138.GA30064@gondor.apana.org.au>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080808231121.GA13158@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49090 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751547AbYHINcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 09:32:00 -0400
Content-Disposition: inline
In-Reply-To: <20080808231121.GA13158@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 04:11:21PM -0700, Suresh Siddha wrote:
>
> b) Looking deeper, do we need to disable interrupts in the kernel_fpu_begin()?
>    Is there a recursive case, where interrupt context also touches FPU/SSE
>    registers?

Even if there wasn't one before, there is going to be one now
because as you pointed out yourself, if we get an inbound IPsec
packet between any kernel_fpu_begin/kernel_fpu_end area, we could
get a nested kernel_fpu_end which puts us back to square one wrt
to the original race.

So clearly we need to think more about this issue.

Unless we can come up with a new solution quickly, I recommend
that we back out the FPU changes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
