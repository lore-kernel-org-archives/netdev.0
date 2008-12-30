From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
	classes
Date: Tue, 30 Dec 2008 07:05:36 +0100
Message-ID: <20081230060536.GG11037@elte.hu>
References: <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu> <20081229123819.GA18321@elte.hu> <20081229124444.GA20306@elte.hu> <20081229141417.GA1493@elte.hu> <20081230035815.GA16454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39985 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbYL3GFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 01:05:55 -0500
Content-Disposition: inline
In-Reply-To: <20081230035815.GA16454@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Dec 29, 2008 at 03:14:17PM +0100, Ingo Molnar wrote:
> >
> > my testing efforts today are not particularly dominated by luck :-)
> > 
> > Below is the latest splat that i got with Peter's patch plus the revert of 
> > dd24c00191 applied.
> 
> > [   78.679386] 
> > [   78.679389] =================================
> > [   78.680039] [ INFO: inconsistent lock state ]
> > [   78.680039] 2.6.28-tip-03885-g44c31d5-dirty #13188
> > [   78.680039] ---------------------------------
> > [   78.680039] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> > [   78.680039] ssh/4054 [HC0[0]:SC1[1]:HE1:SE0] takes:
> > [   78.680039]  (key#8){-+..}, at: [<c042710e>] __percpu_counter_add+0x52/0x7a
> > [   78.680039] {softirq-on-W} state was registered at:
> > [   78.680039]   [<c0163e6e>] __lock_acquire+0x288/0xa93
> > [   78.680039]   [<c01646d6>] lock_acquire+0x5d/0x7a
> > [   78.680039]   [<c0ae0473>] _spin_lock+0x20/0x2f
> > [   78.680039]   [<c042710e>] __percpu_counter_add+0x52/0x7a
> > [   78.680039]   [<c09c3e2f>] percpu_counter_add+0xf/0x12
> > [   78.680039]   [<c09c50ef>] tcp_v4_init_sock+0xe5/0xea
> 
> Right, this is the correct version of the earlier splat :)
> 
> Anyway, I've extended Peter's patch to cover the other cases.
> Please let me know if it still bitches with this + Peter's fbc
> patch.
> 
> net: Fix percpu counters deadlock
> 
> When we converted the protocol atomic counters such as the orphan
> count and the total socket count deadlocks were introduced due to
> the mismatch in BH status of the spots that used the percpu counter
> operations.
> 
> Based on the diagnosis and patch by Peter Zijlstra, this patch
> fixes these issues by disabling BH where we may be in process
> context.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

thanks, will start testing it now.

One small nit: could you please add the Reported-by line for Jeff Kirscher 
who reported the problem originally:

 Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

	Ingo
