From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Mon, 16 Sep 2013 21:25:59 -0400 (EDT)
Message-ID: <20130916.212559.252825159014181091.davem@davemloft.net>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, amirv@mellanox.com,
	ogerlitz@mellanox.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3IQB0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:26:01 -0400
In-Reply-To: <1379075438-20240-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Fri, 13 Sep 2013 08:30:38 -0400

> @@ -2563,7 +2563,7 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev, int slave,
>  {
>  	int err;
>  	int cqn = vhcr->in_modifier;
> -	struct res_cq *cq;
> +	struct res_cq *uninitialized_var(cq);
>  
>  	err = cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED, &cq);
>  	if (err)

This gross annotation is not necessary.

Make cq_res_start_move_to() return 'cq' as an error pointer instead of
setting 'cq' by reference.
