From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix races with reqsk timers
Date: Mon, 10 Aug 2015 21:18:21 -0700 (PDT)
Message-ID: <20150810.211821.2246516216165801977.davem@davemloft.net>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbbHKESW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:18:22 -0400
In-Reply-To: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Aug 2015 09:09:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> reqsk_queue_destroy() and reqsk_queue_unlink() should use
> del_timer_sync() instead of del_timer() before calling reqsk_put(),
> otherwise we could free a req still used by another cpu.
> 
> But before doing so, reqsk_queue_destroy() must release syn_wait_lock
> spinlock or risk a dead lock, as reqsk_timer_handler() might
> need to take this same spinlock from reqsk_queue_unlink() (called from
> inet_csk_reqsk_queue_drop())
> 
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
