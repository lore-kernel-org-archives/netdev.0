From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: avoid costly atomic operation in
 fq_dequeue()
Date: Mon, 06 Oct 2014 00:55:29 -0400 (EDT)
Message-ID: <20141006.005529.1177842595653176576.davem@davemloft.net>
References: <1412442691.17245.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaJFEzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:55:31 -0400
In-Reply-To: <1412442691.17245.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Oct 2014 10:11:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Standard qdisc API to setup a timer implies an atomic operation on every
> packet dequeue : qdisc_unthrottled()
> 
> It turns out this is not really needed for FQ, as FQ has no concept of
> global qdisc throttling, being a qdisc handling many different flows,
> some of them can be throttled, while others are not.
> 
> Fix is straightforward : add a 'bool throttle' to
> qdisc_watchdog_schedule_ns(), and remove calls to qdisc_unthrottled()
> in sch_fq.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
