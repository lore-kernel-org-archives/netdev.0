From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bnx2x: Fix busy_poll vs netpoll
Date: Wed, 15 Apr 2015 17:25:40 -0400 (EDT)
Message-ID: <20150415.172540.2003542806481345239.davem@davemloft.net>
References: <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
	<1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, netdev@vger.kernel.org, bind@enas.net,
	peter@hurleysoftware.com, Ariel.Elior@qlogic.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbbDOVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 17:25:42 -0400
In-Reply-To: <1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Apr 2015 18:45:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 9a2620c877454 ("bnx2x: prevent WARN during driver unload")
> switched the napi/busy_lock locking mechanism from spin_lock() into
> spin_lock_bh(), breaking inter-operability with netconsole, as netpoll
> disables interrupts prior to calling our napi mechanism.
> 
> This switches the driver into using atomic assignments instead of the
> spinlock mechanisms previously employed.
> 
> Based on initial patch from Yuval Mintz & Ariel Elior
> 
> I basically added softirq starvation avoidance, and mixture
> of atomic operations, plain writes and barriers.
> 
> Note this slightly reduces the overhead for this driver when no
> busy_poll sockets are in use.
> 
> Fixes: 9a2620c877454 ("bnx2x: prevent WARN during driver unload")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
