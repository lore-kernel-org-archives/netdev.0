From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: eliminate risk of finding
 to-be-deleted node instance
Date: Thu, 25 Feb 2016 17:06:33 -0500 (EST)
Message-ID: <20160225.170633.2220739017957131099.davem@davemloft.net>
References: <1456329619-9209-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbcBYWGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:06:36 -0500
In-Reply-To: <1456329619-9209-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 24 Feb 2016 11:00:19 -0500

> Although we have never seen it happen, we have identified the
> following problematic scenario when nodes are stopped and deleted:
> 
> CPU0:                            CPU1:
> 
> tipc_node_xxx()                                   //ref == 1
>    tipc_node_put()                                //ref -> 0
>                                  tipc_node_find() // node still in table
>        tipc_node_delete()
>          list_del_rcu(n. list)
>                                  tipc_node_get()  //ref -> 1, bad
>          kfree_rcu()
> 
>                                  tipc_node_put() //ref to 0 again.
>                                  kfree_rcu()     // BOOM!
> 
> We fix this by introducing use of the conditional kref_get_if_not_zero()
> instead of kref_get() in the function tipc_node_find(). This eliminates
> any risk of post-mortem access.
> 
> Reported-by: Zhijiang Hu <huzhijiang@gmail.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
