From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix race in reqsk_queue_unlink()
Date: Mon, 05 Oct 2015 04:05:43 -0700 (PDT)
Message-ID: <20151005.040543.1114187809443016020.davem@davemloft.net>
References: <1443703166.32531.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbbJEKuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:50:04 -0400
In-Reply-To: <1443703166.32531.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2015 05:39:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> reqsk_timer_handler() tests if icsk_accept_queue.listen_opt
> is NULL at its beginning.
> 
> By the time it calls inet_csk_reqsk_queue_drop() and
> reqsk_queue_unlink(), listener might have been closed and
> inet_csk_listen_stop() had called reqsk_queue_yank_acceptq()
> which sets icsk_accept_queue.listen_opt to NULL
> 
> We therefore need to correctly check listen_opt being NULL
> after holding syn_wait_lock for proper synchronization.
> 
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
> Fixes: b357a364c57c ("inet: fix possible panic in reqsk_queue_unlink()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
