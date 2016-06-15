From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net_sched: prio: insure proper transactional
 behavior
Date: Wed, 15 Jun 2016 12:30:43 -0700 (PDT)
Message-ID: <20160615.123043.1799077853807122411.davem@davemloft.net>
References: <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465842812.7945.175.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932321AbcFOTao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:30:44 -0400
In-Reply-To: <1465842812.7945.175.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Jun 2016 11:33:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Now prio_init() can return -ENOMEM, it also has to make sure
> any allocated qdiscs are freed, since the caller (qdisc_create()) wont
> call ->destroy() handler for us.
> 
> More generally, we want a transactional behavior for "tc qdisc
> change ...", so prio_tune() should not make modifications if
> any error is returned.
> 
> It means that we must validate parameters and allocate missing qdisc(s)
> before taking root qdisc lock exactly once, to not leave the prio qdisc
> in an intermediate state.
> 
> Fixes: cbdf45116478 ("net_sched: prio: properly report out of memory errors")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
