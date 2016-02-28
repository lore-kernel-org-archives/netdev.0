From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/10] net/mlx5: Fix global UAR mapping
Date: Sun, 28 Feb 2016 00:43:40 -0500 (EST)
Message-ID: <20160228.004340.1152028301149683990.davem@davemloft.net>
References: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
	<1456418000-18898-10-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com, moshel@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbcB1Fnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 00:43:45 -0500
In-Reply-To: <1456418000-18898-10-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 25 Feb 2016 18:33:19 +0200

> @@ -246,11 +246,11 @@ int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
>  		err = -ENOMEM;
>  		goto err_free_uar;
>  	}
> -
> -	if (mdev->priv.bf_mapping)
> -		uar->bf_map = io_mapping_map_wc(mdev->priv.bf_mapping,
> -						uar->index << PAGE_SHIFT);
> -
> +#ifdef ARCH_HAS_IOREMAP_WC
> +	uar->bf_map = ioremap_wc(pfn << PAGE_SHIFT, PAGE_SIZE);
> +	if (!uar->bf_map)
> +		mlx5_core_warn(mdev, "ioremap_wc() failed\n");
> +#endif

Sorry, this looks very wrong to me.

It makes no sense to only map this resource if ARCH_HAS_IOREMAP_WC
defined.

The interface _always_ exists, and ARCH_HAS_IOREMAP_WC is an internal
symbol that include/asm-generic/iomap.h uses to determine whether to
provide a generic implementation of the interface or not.

I'm not applying this series until you either fix or explain what
you are doing here in the commit message.

Thanks.
