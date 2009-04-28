From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 14:40:33 +0200
Message-ID: <20090428124033.GA1655@elte.hu>
References: <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain> <alpine.LFD.2.00.0904271602390.22156@localhost.localdomain> <49F6A8FD.3010804@cosmosbay.com> <20090428.045342.206106171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	mathieu.desnoyers@polymtl.ca, jarkao2@gmail.com, paulus@samba.org,
	paulmck@linux.vnet.ibm.com, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54660 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbZD1Mlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 08:41:36 -0400
Content-Disposition: inline
In-Reply-To: <20090428.045342.206106171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 28 Apr 2009 08:58:05 +0200
> 
> > I am not sure my day job will permit me to polish a patch mixing all
> > the bits and comments. But I am glad we eventually got back spinlocks
> > which are probably better than rwlocks for implementing this stuff.
> > 
> > Instead of submitting a full patch again, we could first submit a new
> >  include file containg all comments and inline functions ?
> > 
> > This include file could be local to netfilter, with a big stick on
> > it to forbids its use on other areas (No changes in Documentation/ )
> > 
> > Then, as soon as we can go back to pure RCU solution, we can 
> > safely delete this controversial-locking-nesting-per-cpu-thing ?
> 
> I say we merge Linus's locking idea into the XV patch, fixup the 
> commit message wording, and move on with life.
> 
> For something that's going to get deleted as soon as the faster 
> grace period RCU stuff is available, it has consumed an inordinate 
> amount of our time :-)

One more reason to factor out this code into general locking code.

The latest code looks a bit similar to the old big-reader-locks hack 
(which got dropped for good many eons ago and with which i deny any 
involvement with, such as having authored it. [oh, did i say that 
out loud? crap.]), implemented cleanly and properly.

IMHO this locking construct should be considered for 
linux/local_lock.h and kernel/local_lock.c. Even if the netfilter 
code drops its use soon afterwards ;-)

[ The _only_ thing i am worried about is the apparent fact that
  there's so much confusion about recursion versus read-access.
  Recursion might be hard to factor out of the netfilter code, and
  maybe it's not even possible realistically (we fought years with
  the BKL and are still fighting it) but if its harms are not even
  _realized_ that difficult task turns into an impossible task ;-) ]

	Ingo
