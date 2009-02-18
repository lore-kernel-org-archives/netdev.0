From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 22:51:40 +0100
Message-ID: <20090218215140.GA3505@elte.hu>
References: <20090218092041.GC3294@elte.hu> <20090218.013007.117003889.davem@davemloft.net> <20090218110144.GA4100@elte.hu> <20090218.133959.193699273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, kaber@trash.net, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39150 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335AbZBRVvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 16:51:55 -0500
Content-Disposition: inline
In-Reply-To: <20090218.133959.193699273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 18 Feb 2009 12:01:44 +0100
> 
> > * David Miller <davem@davemloft.net> wrote:
> > 
> > | Introduce mod_timer_noact() which for example is to replace 
> > | the calls to del_timer()/add_timer() in 
> > | __nf_ct_refresh_acct(). It works like mod_timer() but doesn't 
> > | activate or modify the timeout of an inactive timer which is 
> > | the behaviour we want in order to be able to use timers as a 
> > | means of synchronization in nf_conntrack.
> > 
> > It does not mention the overhead to the regular timer interfaces 
> > at all, nor does it explain the reasons for this change 
> > adequately.
> 
> You (conveniently) skipped this part of his commit message, so
> I guess this is the part you didn't read very carefully:
> 
> 	A later patch will modify __nf_ct_refresh_acct() to use
> 	mod_timer_noact() which will then save one spin_lock_irqsave()
> 	/ spin_lock_irqrestore() pair per conntrack timer update. This
> 	will also get rid of the race we currently have without adding
> 	more locking in nf_conntrack.
> 
> The whole point is to avoid two spin_lock_irqsave() sequences, thus
> taking the timer locks twice.
> 
> So Ingo, when you say in response:
> 
> 	Why don't you use?
> 
> 		if (del_timer())
> 			add_timer();
> 
> you really look foolish and, in fact, disrespectful to Stephen.
> 
> This was my objection to your email, it proved that you didn't
> really read his changelog message.  He explained perfectly well
> what the final goal was of his changes.
> 
> And you have this knee-jerk reaction quite often.

You accusing me of knee-jerk reaction is the joke of the century 
;-)

Anyway, it's all handled, you just need to read the rest of the 
thread.

Thanks,

	Ingo
