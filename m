From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 22:47:51 +0200
Message-ID: <CAJZOPZJF=uZWGeC_NMw4u+D6YxkmzNNwRQJ24whvvtNshxkx2Q@mail.gmail.com>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:45999 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3LKUrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:47:51 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so10693840pbc.39
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 12:47:51 -0800 (PST)
In-Reply-To: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 Shawn Bohrer <shawn.bohrer@gmail.com> wrote:

> @@ -264,10 +267,6 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
>         mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
>                 mdev->port_cnt++;
>
> -       /* Initialize time stamp mechanism */
> -       if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
> -               mlx4_en_init_timestamp(mdev);
> -
>         mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
>                 if (!dev->caps.comp_pool) {
>                         mdev->profile.prof[i].rx_ring_num =
> @@ -305,6 +304,10 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
>                         mdev->pndev[i] = NULL;
>         }
>
> +       /* Initialize time stamp mechanism */
> +       if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
> +               mlx4_en_init_timestamp(mdev);
> +
>         return mdev;

so you are reverting here commit 1ec4864b1017 "net/mlx4_en: Fixed
crash when port type is changed" -- why?
