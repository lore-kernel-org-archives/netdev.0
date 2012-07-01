From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] net/mlx4_core: Change resource tracking
 mechanism to use red-black tree
Date: Sun, 01 Jul 2012 03:17:46 -0700 (PDT)
Message-ID: <20120701.031746.1509824948499955130.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242Ab2GAKRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:17:49 -0400
In-Reply-To: <1341135823-29039-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:34 +0300

> @@ -733,7 +776,7 @@ static int qp_res_start_move_to(struct mlx4_dev *dev, int slave, int qpn,
>  	int err = 0;
>  
>  	spin_lock_irq(mlx4_tlock(dev));
> -	r = radix_tree_lookup(&tracker->res_tree[RES_QP], qpn);
> +	r = (struct res_qp *)res_tracker_lookup(&tracker->res_tree[RES_QP], qpn);
>  	if (!r)
>  		err = -ENOENT;
>  	else if (r->com.owner != slave)

Casts are terrible, return "void *" from res_tracker_lookup() just as
radix_tree_lookup() does.

Also you have indentation problems all over this patch.  When you have
a multi-line function call the first non-whitespace character on the
second and subsequent lines should line up with the first column after
the openning parenthesis on the first line.
