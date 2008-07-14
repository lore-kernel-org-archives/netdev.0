From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 02/10] mlx4_en: Device initialization
Date: Mon, 14 Jul 2008 17:48:32 +0100
Message-ID: <20080714164831.GT19302@solarflare.com>
References: <487B6571.8000602@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:38237 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757536AbYGNQsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 12:48:41 -0400
Content-Disposition: inline
In-Reply-To: <487B6571.8000602@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
> +{
> +	struct mlx4_en_dev *mdev = endev_ptr;
> +	int p;
> +
> +	down(&mdev->state_sem);
> +	mdev->state = DEVICE_DOWN;
> +	up(&mdev->state_sem);
> +
> +	for (p = 1; p <= MLX4_MAX_PORTS; ++p)
> +		if (mdev->pndev[p])
> +			mlx4_en_destroy_netdev(mdev->pndev[p]);
[...]
> +static void *mlx4_en_add(struct mlx4_dev *dev)
> +{
[...]
> +	/* Create a netdev for each port */
> +	mlx4_foreach_port(i, mdev->ports_map) {
> +		mlx4_info(mdev, "Activating port:%d\n", i);
> +		if (mlx4_en_init_netdev(mdev, i, &mdev->profile.prof[i])) {
> +			mdev->pndev[i] = NULL;
> +			goto err_free_netdev;
> +		}
> +	}
> +	return mdev;
> +
> +
> +err_free_netdev:
> +	for (i = 0; i < dev->caps.num_ports; i++) {
> +		if (mdev->pndev[i])
> +			mlx4_en_destroy_netdev(mdev->pndev[i]);
> +	}
[...]

These three loops need to loop over the same set of devices, so why are they
written completely differently?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
