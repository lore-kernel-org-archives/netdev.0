From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/mlx4_core: Add an option to configure
 SVLAN TPID
Date: Thu, 7 Jul 2016 22:38:24 +0300
Message-ID: <CAJ3xEMho+6W_r3kEuq2+tCD1FZfW0M0xJzS-VGLUD9fK17u+1Q@mail.gmail.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com> <1467808146-29573-5-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35442 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbcGGTi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 15:38:26 -0400
Received: by mail-oi0-f66.google.com with SMTP id e84so307958oib.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 12:38:25 -0700 (PDT)
In-Reply-To: <1467808146-29573-5-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 3:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Moshe Shemesh <moshe@mellanox.com>
>
> Expose mlx4_config_svlan_tpid, that checks for feature support
> in device capabilities and sets the Service Tag TPID accordingly.

I Googled for service tag TPID and I understand this is what we can
vlan protcol, correct? any reason to call it differently?


> @@ -2286,6 +2291,7 @@ struct mlx4_config_dev {
>  #define MLX4_VXLAN_UDP_DPORT (1 << 0)
>  #define MLX4_ROCE_V2_UDP_DPORT BIT(3)
>  #define MLX4_DISABLE_RX_PORT BIT(18)
> +#define MLX4_SVLAN_TPID BIT(20)
>
>  static int mlx4_CONFIG_DEV_set(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
>  {
> @@ -2372,6 +2378,8 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
>
>         params->vxlan_udp_dport = be16_to_cpu(config_dev.vxlan_udp_dport);
>
> +       params->svlan_tpid = be16_to_cpu(config_dev.svlan_tpid);
> +
>         return 0;
>  }
>  EXPORT_SYMBOL_GPL(mlx4_config_dev_retrieval);
> @@ -2414,6 +2422,21 @@ int mlx4_config_roce_v2_port(struct mlx4_dev *dev, u16 udp_port)
>  }
>  EXPORT_SYMBOL_GPL(mlx4_config_roce_v2_port);
>
> +int mlx4_config_svlan_tpid(struct mlx4_dev *dev, __be16 svlan_tpid)
> +{
> +       struct mlx4_config_dev config_dev;
> +
> +       if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SVLAN_TPID))
> +               return -ENOTSUPP;
> +
> +       memset(&config_dev, 0, sizeof(config_dev));
> +       config_dev.update_flags    = cpu_to_be32(MLX4_SVLAN_TPID);
> +       config_dev.svlan_tpid = svlan_tpid;
> +
> +       return mlx4_CONFIG_DEV_set(dev, &config_dev);
> +}
> +EXPORT_SYMBOL_GPL(mlx4_config_svlan_tpid);

dead code? I don't see any invocation of this helper on the patch, if
it's on earlier patches of the series it means you broke bisection...
