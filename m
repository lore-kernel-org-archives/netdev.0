From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] xfrm: remove useless hash_resize_mutex
 locks
Date: Mon, 14 Jul 2014 18:51:50 -0700 (PDT)
Message-ID: <20140714.185150.757251885307832898.davem@davemloft.net>
References: <1405388021-29105-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, shan.hai@windriver.com,
	netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbaGOBvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 21:51:51 -0400
In-Reply-To: <1405388021-29105-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 15 Jul 2014 09:33:41 +0800

> In xfrm_policy.c, hash_resize_mutex is defined as a local variable
> and only used in xfrm_hash_resize() which is declared as a work
> handler of xfrm.policy_hash_work. But when the xfrm.policy_hash_work
> work is put in the global workqueue(system_wq) with schedule_work(),
> the work will be really inserted in the global workqueue if it was
> not already queued, otherwise, it is still left in the same position
> on the the global workqueue. This means the xfrm_hash_resize() work
> handler is only executed once at any time no matter how many times
> its work is scheduled, that is, xfrm_hash_resize() is not called
> concurrently at all, so hash_resize_mutex is redundant for us.
> 
> Additionally hash_resize_mutex defined in xfrm_state.c can be removed
> as the same reason.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

This looks correct to me:

Acked-by: David S. Miller <davem@davemloft.net>
