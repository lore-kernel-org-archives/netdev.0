From: Damien Wyart <damien.wyart@free.fr>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 10:04:20 +0200
Message-ID: <20090525080420.GA10127@localhost.localdomain>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com> <20090524221240.GI24757@kvack.org> <4A19CE8B.3070302@cosmosbay.com> <20090525000050.GJ24757@kvack.org> <4A1A2AFA.8020605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost-c5-p0.nerim.net ([195.5.209.11]:65499 "EHLO
	smtp-delay1.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751405AbZEYIUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 04:20:02 -0400
Content-Disposition: inline
In-Reply-To: <4A1A2AFA.8020605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

* Eric Dumazet <dada1@cosmosbay.com> [2009-05-25 07:22]:
> Time to include Paul and lkml in the discussion, and find a better
> solution than one provided in February.

> > bf51935f3e988e0ed6f34b55593e5912f990750a is first bad commit
> > commit bf51935f3e988e0ed6f34b55593e5912f990750a
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Tue Feb 17 06:01:30 2009 -0800

> >     x86, rcu: fix strange load average and ksoftirqd behavior

> >     Damien Wyart reported high ksoftirqd CPU usage (20%) on an
> >     otherwise idle system.

> >     The function-graph trace Damien provided:
> > ...
> > diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c

> > index a546f55..bd4da2a 100644
> > --- a/arch/x86/kernel/process_32.c
> > +++ b/arch/x86/kernel/process_32.c
> > @@ -104,9 +104,6 @@ void cpu_idle(void)
> >  			check_pgt_cache();
> >  			rmb();

> > -			if (rcu_pending(cpu))
> > -				rcu_check_callbacks(cpu, 0);
> > -
> >  			if (cpu_is_offline(cpu))
> >  				play_dead();

> I wonder if the real root of the problem was not discovered in the meantime,
> by commit 64ca5ab913f1594ef316556e65f5eae63ff50cee
> rcu: increment quiescent state counter in ksoftirqd()

> Maybe this commit solved Damien Wyart problem as well, and we can revert
> commit bf51935f3e988e0ed6f34b55593e5912f990750a ?

Ran some tests on 2.6.30-rc7 with bf51935f reverted, and I am still
seeing the problems I originally reported back in February, so I guess
64ca5ab9 is not enough to fully solve all the issues... Note that I am
using CONFIG_TREE_RCU=y (was already true in my February reports).

Feel free to ask if more testing is needed.

-- 
Damien Wyart
