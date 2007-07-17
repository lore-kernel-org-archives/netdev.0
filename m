From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Mon, 16 Jul 2007 18:28:53 -0700 (PDT)
Message-ID: <20070716.182853.121295652.davem@davemloft.net>
References: <20070716070032.GA1871@ff.dom.local>
	<469B6CA4.9030205@trash.net>
	<1184607905.18564.50.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jarkao2@o2.pl, netdev@vger.kernel.org
To: ranko@spidernet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756797AbXGQB2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:28:51 -0400
In-Reply-To: <1184607905.18564.50.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ranko Zivojnovic <ranko@spidernet.net>
Date: Mon, 16 Jul 2007 20:45:05 +0300

> [NET] gen_estimator deadlock fix
> 
> -Fixes ABBA deadlock noted by Patrick McHardy <kaber@trash.net>:
> 
> > There is at least one ABBA deadlock, est_timer() does:
> > read_lock(&est_lock)
> > spin_lock(e->stats_lock) (which is dev->queue_lock)
> >
> > and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> > calls htb_destroy_class, then gen_kill_estimator and this
> > write_locks est_lock.
> 
> To fix the ABBA deadlock the rate estimators are now kept on an rcu list.
> 
> -The est_lock changes the use from protecting the list to protecting
> the update to the 'bstat' pointer in order to avoid NULL dereferencing.
> 
> -The 'interval' member of the gen_estimator structure removed as it is
> not needed.
> 
> Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>

Applied, thanks.
