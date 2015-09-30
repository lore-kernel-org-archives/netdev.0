From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 RESEND] BNX2: fix a Null Pointer for
 stats_blk
Date: Tue, 29 Sep 2015 21:10:11 -0700 (PDT)
Message-ID: <20150929.211011.677113057504126372.davem@davemloft.net>
References: <56014CC0.3050201@huawei.com>
	<5608E5DE.6010706@huawei.com>
	<560A02FA.6030309@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rui.xiang@huawei.com, manish.chopra@qlogic.com
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560A02FA.6030309@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Tue, 29 Sep 2015 11:18:18 +0800

> @@ -839,11 +828,12 @@ bnx2_free_mem(struct bnx2 *bp)
>  }
> 
>  static int
> -bnx2_alloc_mem(struct bnx2 *bp)
> +bnx2_alloc_stats_blk(struct net_device *dev)
>  {
> -	int i, status_blk_size, err;
> +	int i, status_blk_size;
>  	struct bnx2_napi *bnapi;
>  	void *status_blk;
> +	struct bnx2 *bp = netdev_priv(dev);
> 
>  	/* Combine status and statistics blocks into one allocation. */
>  	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));

This function is not just allocating the stats block, it's allocating
a whole bunch of other things too.

Only allocate the stats block at probe time, not the NAPI et al. stuff
as well.  That can safely stay in the open/close paths.
