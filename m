From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: fix THROTTLED/RUNNING race
Date: Thu, 24 Mar 2011 00:13:46 -0700 (PDT)
Message-ID: <20110324.001346.241938423.davem@davemloft.net>
References: <1300034690.2761.29.camel@edumazet-laptop>
	<1300862758.2717.41.camel@edumazet-laptop>
	<1300949637.2810.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, fchecconi@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933167Ab1CXHNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 03:13:08 -0400
In-Reply-To: <1300949637.2810.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Mar 2011 07:53:57 +0100

> [PATCH] net_sched: fix THROTTLED/RUNNING race
> 
> commit fd245a4adb52 (net_sched: move TCQ_F_THROTTLED flag)
> added a race.
> 
> qdisc_watchdog() is run from softirq, so special care should be taken or
> we can lose one state transition (THROTTLED/RUNNING)
> 
> Prior to fd245a4adb52, we were manipulating q->flags (qdisc->flags &=
> ~TCQ_F_THROTTLED;) and this manipulation could only race with
> qdisc_warn_nonwc().
> 
> Since we want to avoid atomic ops in qdisc fast path - it was the
> meaning of commit 371121057607e (QDISC_STATE_RUNNING dont need atomic
> bit ops) - fix is to move THROTTLE bit into 'state' field, this one
> being manipulated with SMP and IRQ safe operations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot for tracking this down Eric.
