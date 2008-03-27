From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 13:22:55 +0100
Message-ID: <20080327122255.GC2845@ami.dom.local>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <20080325134320.21525479.akpm@linux-foundation.org> <47EAD8A5.3070806@gmail.com> <20080326171403.ad186037.akpm@linux-foundation.org> <20080327085542.GA2778@ami.dom.local> <20080327021812.601776b8.akpm@linux-foundation.org> <1206615379.8514.502.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:62169 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756021AbYC0MRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:17:18 -0400
Received: by rn-out-0910.google.com with SMTP id e24so3316947rng.1
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 05:17:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1206615379.8514.502.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 11:56:19AM +0100, Peter Zijlstra wrote:
> On Thu, 2008-03-27 at 02:18 -0700, Andrew Morton wrote:
...
> > I bet the net code is wrong and we missed it ;)

It looks like you are natural born winner! Congratulations!

> How about this:
> 
> <irqs disabled>
> 
>   netpoll_poll()
>     poll_napi()
>       spin_trylock(&napi->poll_lock)
>       poll_one_napi()
>         napi->poll() := sky2_poll()
>           napi_complete()
>             local_irq_disable()
>             local_irq_enable() <--- *BUG*

Yes! I missed it's unconditional here... Great catch!

On the other hand, still a question why lockdep doesn't see this
every day?

Jarek P.
