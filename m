From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rebalance locks by converting write_lock_bh to
 write_lock+local_bh_disable
Date: Sat, 23 Nov 2013 14:39:29 -0800 (PST)
Message-ID: <20131123.143929.975712910203893827.davem@davemloft.net>
References: <20131121235402.GA11774@opentech.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, eric.dumazet@gmail.com, roque@di.fc.ul.pt,
	peterz@infradead.org, netdev@vger.kernel.org
To: der.herr@hofr.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551Ab3KWWbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:31:33 -0500
In-Reply-To: <20131121235402.GA11774@opentech.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Fri, 22 Nov 2013 00:54:02 +0100

> From 2c8e669b691b825c0ed2a02bd7a698d8ed5c6d29 Mon Sep 17 00:00:00 2001
> From: Nicholas Mc Guire <der.herr@hofr.at>
> Date: Thu, 21 Nov 2013 18:22:55 -0500
> Subject: [PATCH] rebalance locks by converting write_lock_bh to write_lock+local_bh_disable
>  
> 
>  in __neigh_event_send write_lock_bh(&neigh->lock) is implicitly balanced by
>  write_unlock(&neigh->lock)+local_bh_disable() - while this is equivalent with
>  respect to the effective low level locking primitives it breaks balancing
>  in the locking api. This makes automatic lock-checking trigger false 
>  positives, creates an implicit dependency between *_lock_bh and *_lock 
>  functions as well as making the extremly simply locking of net core even
>  easier to understand.
> 
>  The api inbalance was introduced in:
>  commit cd28ca0a3dd17c68d24b839602a0e6268ad28b5d
>  Author: Eric Dumazet <eric.dumazet@gmail.com>
>  This patch just rebalances the lock api
> 
>  No change of functionality
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>

This is a valid locking idiom, fix the lock checking.
