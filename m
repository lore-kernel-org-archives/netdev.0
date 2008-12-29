From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 23:49:42 +1100
Message-ID: <20081229124942.GA11343@gondor.apana.org.au>
References: <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu> <20081229123819.GA18321@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42933 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750887AbYL2Mty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 07:49:54 -0500
Content-Disposition: inline
In-Reply-To: <20081229123819.GA18321@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 01:38:19PM +0100, Ingo Molnar wrote:
>
> hm, even with the revert i got the splat below. So some other commits are 
> causing this too?

Indeed, there is more :)

> stack backtrace:
> Pid: 1435, comm: kjournald Not tainted 2.6.28-tip-03883-gf855e6c-dirty #13150
> Call Trace:
>  [<c015a0d6>] print_usage_bug+0x176/0x1d0
>  [<c015b800>] mark_lock+0xbd0/0xd80
>  [<c015da13>] __lock_acquire+0x483/0xae0
>  [<c015bcdb>] ? trace_hardirqs_on+0xb/0x10
>  [<c015e0f9>] lock_acquire+0x89/0xc0
>  [<c034fc75>] ? __percpu_counter_add+0x65/0xb0
>  [<c07247a8>] _spin_lock+0x38/0x50
>  [<c034fc75>] ? __percpu_counter_add+0x65/0xb0
>  [<c034fc75>] __percpu_counter_add+0x65/0xb0
>  [<c060dc49>] tcp_v4_destroy_sock+0x1d9/0x240

This came from 1748376b6626acf59c24e9592ac67b3fe2a0e026 which also
has the same bug (although this particular trace is bogus and is
fixed by Peter's first patch).

I think these are the only two percpu counter patches around that
time frame.

Also watch out for 6976a1d6c222c50ac93d2273b9cf57e6fd047e59 when
reverting.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
