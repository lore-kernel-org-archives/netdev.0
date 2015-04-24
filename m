From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix possible panic in reqsk_queue_unlink()
Date: Fri, 24 Apr 2015 11:39:30 -0400 (EDT)
Message-ID: <20150424.113930.411412345479090439.davem@davemloft.net>
References: <1429837424.22254.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbbDXPjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:39:31 -0400
In-Reply-To: <1429837424.22254.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Apr 2015 18:03:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> [ 3897.923145] BUG: unable to handle kernel NULL pointer dereference at
>  0000000000000080
> [ 3897.931025] IP: [<ffffffffa9f27686>] reqsk_timer_handler+0x1a6/0x243
> 
> There is a race when reqsk_timer_handler() and tcp_check_req() call
> inet_csk_reqsk_queue_unlink() on the same req at the same time.
> 
> Before commit fa76ce7328b2 ("inet: get rid of central tcp/dccp listener
> timer"), listener spinlock was held and race could not happen.
> 
> To solve this bug, we change reqsk_queue_unlink() to not assume req
> must be found, and we return a status, to conditionally release a
> refcount on the request sock.
> 
> This also means tcp_check_req() in non fastopen case might or not
> consume req refcount, so tcp_v6_hnd_req() & tcp_v4_hnd_req() have
> to properly handle this.
> 
> (Same remark for dccp_check_req() and its callers)
> 
> inet_csk_reqsk_queue_drop() is now too big to be inlined, as it is
> called 4 times in tcp and 3 times in dccp.
> 
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Eric.
