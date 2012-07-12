From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] ieee802.15.4 general fixes
Date: Thu, 12 Jul 2012 07:56:25 -0700 (PDT)
Message-ID: <20120712.075625.2029928789684872933.davem@davemloft.net>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932571Ab2GLO40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:56:26 -0400
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Wed, 11 Jul 2012 11:22:41 +0400

> Dear David, Eric,
> 
> this patch-set is mostly intended to fix sparse and LOCKDEP warnings.
> It mostly contains some my previous patches reworked and extended according
> to the hints from Eric Dumazet and Fengguang Wu. Many thanks to they!
> 
> Changes since v1:
> 1. A new patch from Tony Cheneau was added. The fragmentation stops working
> after some amount of packets sent. This patch fixes this issue.
> 2. 6lowpan fragment deleting routine: I removed spinlocks from timer_expired
> handler and use spin_lock_bh to disable concurrency races with timer interrupt.
> 3. at86rf230 irq handler was a little bit modified

Series applied, but you don't need to grab a spinlock to only
load one interger from some datastructure.  I mean:

	lock();
	ret = p->foo;
	unlock();

is completely pointless.
