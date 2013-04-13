From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Sat, 13 Apr 2013 08:03:39 -0400
Message-ID: <20130413120339.GA8168@neilslaptop.think-freely.org>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
 <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54259 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767Ab3DMMDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 08:03:50 -0400
Content-Disposition: inline
In-Reply-To: <51690AAB.1030102@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 13, 2013 at 09:35:07AM +0200, Bart Van Assche wrote:
> On 04/12/13 20:45, Neil Horman wrote:
> >On Fri, Apr 12, 2013 at 04:01:04PM +0200, Bart Van Assche wrote:
> >>On 04/12/13 13:32, Neil Horman wrote:
> >>I think there is another issue with invoking mutex_trylock() and mutex_unlock()
> >>from IRQ context: as far as I can see if CONFIG_DEBUG_MUTEXES is disabled
> >>__mutex_unlock_common_slowpath() uses spin_lock() to lock mutex.wait_lock and
> >>hence invoking mutex_unlock() from both non-IRQ and IRQ context is not safe.
> >>Any thoughts about that ?
> >>
> >Yeah, its ugly, but in this specific case, its ok.  the netpoll code (in
> >netpoll_send_skb disables irq on the local cpu before entering the netpoll code
> >path any further, so whenver we frob this mutex from the local cpu, we're
> >guaranteed not to get pre-empted by an irq.
> 
> As far as I know it is neither allowed nor safe to call
> netpoll_rx_disable() with IRQs disabled. But that function can lock
Where do you see netpoll_rx_disable getting called with irqs disabled?

> the dev_lock mutex. What do you think will happen with
> CONFIG_DEBUG_MUTEXES=n if an interrupt occurs during the
> mutex_lock(&ni->dev_lock) call, that mutex_lock() call has already
> locked the mutex-internal spin lock via spin_lock() and
> mutex_trylock() is invoked from inside the interrupt ? Can that
> result in anything else than deadlock and "CPU stuck" messages ?
> 
Please go back and look more closely.  Where do you see a mutex_lock call
getting made with interrupts enabled?

Neil
