From: eran ben elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Thu, 24 Dec 2015 16:02:14 +0200
Message-ID: <CAKHjkj=qr3vmLQW2jJc-7SECvV9GWM_A1Ydh2JxR8wEZm1=xeA@mail.gmail.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
	<1450647991-13736-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34450 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbbLXOCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 09:02:15 -0500
Received: by mail-wm0-f67.google.com with SMTP id l126so33887087wml.1
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 06:02:14 -0800 (PST)
In-Reply-To: <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +void mlx5e_fill_hwstamp(struct mlx5e_tstamp *tstamp,
> +                       struct skb_shared_hwtstamps *hwts,
> +                       u64 timestamp)
> +{
> +       unsigned long flags;
> +       u64 nsec;
> +
> +       memset(hwts, 0, sizeof(struct skb_shared_hwtstamps));
> +       read_lock_irqsave(&tstamp->lock, flags);

Richard and others,
Any special reason to use read_lock_irqsave and not just read_lock?
On second thought could not see any good reason for that,
but saw many other examples which uses irqsave.

thanks,
Eran

> +       nsec = timecounter_cyc2time(&tstamp->clock, timestamp);
> +       read_unlock_irqrestore(&tstamp->lock, flags);
> +
> +       hwts->hwtstamp = ns_to_ktime(nsec);
> +}
> +
> +static cycle_t mlx5e_read_clock(const struct cyclecounter *cc)
> +{
> +       struct mlx5e_tstamp *tstamp = container_of(cc, struct mlx5e_tstamp,
> +                                                  cycles);
> +       struct mlx5e_priv *priv = container_of(tstamp, struct mlx5e_priv,
> +                                              tstamp);
> +
> +       return mlx5_core_read_clock(priv->mdev) & cc->mask;
> +}
> +
