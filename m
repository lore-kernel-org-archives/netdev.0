From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 18:29:31 +0800
Message-ID: <20080328102931.GA23039@gondor.apana.org.au>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos.Worku@Sun.COM, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca,
	Ingo Molnar <mingo@elte.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43608 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753182AbYC1K3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 06:29:46 -0400
Content-Disposition: inline
In-Reply-To: <20080327.183844.74572930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 06:38:44PM -0700, David Miller wrote:
>
> This runs from softirqs, the local thread's scheduling
> state is updated from timers which also run from softirqs,
> so this need_resched() test won't work.

I had a trawl through the scheduler/timer code and it appears
that even with softirqs disabled we should able to set the flag
through this call chain (on x86-32):

timer_interrupt => do_timer_interrupt_hook => tick_handle_periodic =>
tick_periodic => update_process_times => scheduler_tick

Ingo, could you confirm that the scheduler is capable of setting
need_resched even with BH disabled?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
