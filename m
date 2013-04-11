From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Thu, 11 Apr 2013 19:51:20 +0200
Message-ID: <3142935.JcJEKt2WmH@cpaasch-mac>
References: <5166BDAA.3000603@acm.org> <2032636.RnfJ0d1BWA@cpaasch-mac> <20130411170404.GE8986@neilslaptop.think-freely.org>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: g@neilslaptop.think-freely.org,
	Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58737 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab3DKRv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:51:27 -0400
In-Reply-To: <20130411170404.GE8986@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 13:04:05 Neil Horman wrote:
> I dont believe the deadlock you describe can happen.  The spin_lock_mutex
> operation disables irqs on the local cpu with local_irq_save, so we won't
> loose the cpu while we're holding the spinlock.  Likewise we don't restore
> the irq flags until after we release said lock.  Once we have the mutex, if
> we're preempted by another path that goes through the netpoll_poll_dev
> path, then we hit the trylock api call.  The spinlock is either released or
> held on another cpu (read: no deadlock), and if the mutex is held, then the
> trylock simply fails.

Thanks for explaining this to me. I was looking for a local_bh_disable() - but 
local_irq_save does the job too.


Thanks,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
