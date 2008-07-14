From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 03/10] mlx4_en: net_device implementation
Date: Mon, 14 Jul 2008 20:42:30 +0100
Message-ID: <20080714194228.GU19302@solarflare.com>
References: <487B657E.2040900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:35685 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755473AbYGNTmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 15:42:40 -0400
Content-Disposition: inline
In-Reply-To: <487B657E.2040900@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +static void mlx4_en_restart(struct work_struct *work)
> +{
> +	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
> +						 watchdog_task);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	struct net_device *dev = priv->dev;
> +
> +	mlx4_dbg(mdev, "Watchdog task called for port %d\n", priv->port);
> +	mlx4_en_stop_port(dev);
> +	if (mlx4_en_start_port(dev))
> +	    mlx4_err(mdev, "Failed restarting port %d\n", priv->port);

The indentation is slightly off here.

> +}
> +
> +
> +int mlx4_en_open(struct net_device *dev)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	int i;
> +	int err = 0;
> +
> +	mlx4_dbg(mdev, "Open called for port:%d\n", priv->port);
> +
> +	down(&mdev->state_sem);

This is already under RTNL; why do you need your own semaphore?
(And why are you using semaphores, not mutexes?)

[...]
> +int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
> +			struct mlx4_en_port_profile *prof)
> +{
[...]
> +#ifdef NETIF_F_TSO
> +	dev->features |= NETIF_F_TSO;
> +#endif
> +#ifdef NETIF_F_TSO6
> +	dev->features |= NETIF_F_TSO6;
> +#endif
[...]

These ifdef's are unneeded; the flags are always defined.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
