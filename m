From: David Miller <davem@davemloft.net>
Subject: Re: lock-warning seen on giving rds-info command
Date: Fri, 18 Nov 2011 12:44:59 -0500 (EST)
Message-ID: <20111118.124459.1019488665580264734.davem@davemloft.net>
References: <1321603654-17179-1-git-send-email-kumaras@chelsio.com>
	<1321604802.2444.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumaras@chelsio.com, netdev@vger.kernel.org,
	venkat.x.venkatsubra@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab1KRRpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 12:45:10 -0500
In-Reply-To: <1321604802.2444.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Nov 2011 09:26:42 +0100

> You mean that following sequence triggers a warning ?
> 
> spin_lock_irqsave(&rds_sock_lock, flags);
> ...
> read_lock_bh(&sk->sk_callback_lock);
> read_unlock_bh(&sk->sk_callback_lock);   // HERE
> ...

This sequence has always been disallowed.

BH's are triggered by software, so when you do local_bh_enable() it checks
to make sure you haven't tried to do this with hard IRQs disabled and
triggers the warning if so.

static void __local_bh_enable(unsigned int cnt)
{
	WARN_ON_ONCE(in_irq());
	WARN_ON_ONCE(!irqs_disabled());
 ...
