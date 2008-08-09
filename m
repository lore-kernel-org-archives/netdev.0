From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 09:49:25 +0800
Message-ID: <20080809014925.GA26529@gondor.apana.org.au>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@ZenIV.linux.org.uk,
	vegard.nossum@gmail.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45262 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751852AbYHIBth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 21:49:37 -0400
Content-Disposition: inline
In-Reply-To: <489C97FB.2030408@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 12:01:15PM -0700, H. Peter Anvin wrote:
>
> It's technically overkill, if (and only if!) these instructions don't 
> actually touch the SSE state (most likely they're using the SSE 
> pipeline, and need this stuff to deal with power management issues.)

Yes the PadLock uses the SSE pipeline, but doesn't touch any
of the state.

> However, overkill is a good way to make sure something is dead. 
> Applying the patch will make sure we fix the regression, and we can 
> worry about optimizing this further post-2.6.27.

Do we really need the FPU changes right now? I'd prefer for that
to be backed out until a proper solution is found.  Disabling
preemption around crypto is really bad for scheduling latency.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
