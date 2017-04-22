From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [RFC] change the default Kconfig value of mlx5_en
Date: Sat, 22 Apr 2017 03:34:06 +0300
Message-ID: <CALzJLG9cLY8qqjFHGx6i=Gi-TH5EZ2Mq+TQOusX7=EoRDvx1tw@mail.gmail.com>
References: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
 <20170421.154745.182611990085743539.davem@davemloft.net> <CAA85sZtBo5dORg4sj8X_SROBU0ySh3_CQh1WiYcVX-RVv4E+gA@mail.gmail.com>
 <CAA85sZtr3N3Y8=R5qZHDTMgquV35ddw0x45qy8Kkf_tiVdu8ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ian Kumlien <ian.kumlien@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34375 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424193AbdDVAe2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:34:28 -0400
Received: by mail-qt0-f196.google.com with SMTP id y33so13840708qta.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:34:27 -0700 (PDT)
In-Reply-To: <CAA85sZtr3N3Y8=R5qZHDTMgquV35ddw0x45qy8Kkf_tiVdu8ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 2:10 AM, Ian Kumlien <ian.kumlien@gmail.com> wrote:
> Sorry,
>
> Back again, fighting cold, hot whiskey has been consumed...
>
> Something like this would perhaps be a better solution:
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> index 60154a175bd3..fe192e247601 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -1139,6 +1139,10 @@ static int mlx5_load_one(struct mlx5_core_dev
> *dev, struct mlx5_priv *priv,
>
>  #ifdef CONFIG_MLX5_CORE_EN
>         mlx5_eswitch_attach(dev->priv.eswitch);
> +#else
> +       if (MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) {
> +               dev_info(&pdev->dev, "Ethernet device discovered but
> support not enabled in kernel.");
> +       }
>  #endif
>

Currently both MLX5_CORE=n and MLX5_CORE_EN=n as a default, the issue
you are seeing can occur only if you explicitly  set MLX5_CORE=y and
MLX5_CORE=n, Why would someone do this if he knows he wants Ethernet
support as well ? IMHO this print is redundant .

Anyway, Are you looking for RDMA support over ethernet (RoCE) ? and
you are not interested to have ethernet netdev support ?

if yes, I think this is something that can be achieved, but the
question is do we really need this ?
