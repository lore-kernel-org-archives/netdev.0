From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-next 05/11] IB/mlx5: Refactor UMR post send format
Date: Sun, 01 Jan 2017 21:11:51 -0500 (EST)
Message-ID: <20170101.211151.1554932382154746164.davem@davemloft.net>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
        <1483305027-2573-6-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, leonro@mellanox.com,
        ilyal@mellanox.com, artemyko@mellanox.com, leon@kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755245AbdABCLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 21:11:53 -0500
In-Reply-To: <1483305027-2573-6-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun,  1 Jan 2017 23:10:21 +0200

> diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
> index a1b3125..6d5f5d4 100644
> --- a/drivers/infiniband/hw/mlx5/qp.c
> +++ b/drivers/infiniband/hw/mlx5/qp.c
> @@ -3080,9 +3080,10 @@ static void set_data_ptr_seg(struct mlx5_wqe_data_seg *dseg, struct ib_sge *sg)
>  	dseg->addr       = cpu_to_be64(sg->addr);
>  }
>  
> -static __be16 get_klm_octo(int npages)
> +static inline u64 get_xlt_octo(u64 bytes)
>  {

Again, please don't use 'inline' in foo.c files.
