From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET] ifb: set separate lockdep classes for queue locks
Date: Thu, 20 Mar 2008 15:37:45 -0700 (PDT)
Message-ID: <20080320.153745.232982215.davem@davemloft.net>
References: <20080308120244.GA3378@ami.dom.local>
	<20080319004547.M71837@visp.net.lb>
	<20080319073441.GA3918@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, denys@visp.net.lb, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756767AbYCTWhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 18:37:33 -0400
In-Reply-To: <20080319073441.GA3918@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 19 Mar 2008 07:34:41 +0000

> Subject: [NET] ifb: set separate lockdep classes for queue locks
> 
> > [2148614.154688] =======================================================
> > [2148614.154805] [ INFO: possible circular locking dependency detected ]
> > [2148614.154862] 2.6.24.3-build-0023 #9
> > [2148614.154913] -------------------------------------------------------
> > [2148614.154969] swapper/0 is trying to acquire lock:
> > [2148614.155023]  (&ifb_queue_lock_key){-+..}, at: [<c0289d4d>] 
> > dev_queue_xmit+0x177/0x302
> > [2148614.155245]
> > [2148614.155246] but task is already holding lock:
> > [2148614.155346]  (&p->tcfc_lock){-+..}, at: [<f8a10066>] tcf_mirred+0x20/
> > 0x180 [act_mirred]
> > [2148614.155569]
> > [2148614.155570] which lock already depends on the new lock.
> 
> lockdep warns of locking order while using ifb with sch_ingress and
> act_mirred: ingress_lock, tcfc_lock, queue_lock (usually queue_lock
> is at the beginning). This patch is only to tell lockdep that ifb is
> a different device (e.g. from eth) and has its own pair of queue
> locks. (This warning is a false-positive in common scenario of using
> ifb; yet there are possible situations, when this order could be
> dangerous; lockdep should warn in such a case.)
> 
> 
> Reported-and-tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>

Jarek, the code in linux/lockdep.h provides dummy do-nothing
versions of the lockdep_*() interfaces, so the spinlock
debug ifdeffing you do here is unnecessary.

Simply include linux/lockdep.h and perform the actions
unconditionally.

For example, this is how net/core/sock.c does things.

Also, please upgrade Jamal's "CC" to an "Acked-by" :-)
