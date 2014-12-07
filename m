From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net/mlx4_en: ethtool force speed when asking
 for autoneg=off
Date: Sun, 07 Dec 2014 14:55:03 +0300
Message-ID: <54844017.2080708@cogentembedded.com>
References: <1417939634-26085-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:37580 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbaLGLzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 06:55:05 -0500
Received: by mail-lb0-f178.google.com with SMTP id f15so2762796lbj.23
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 03:55:04 -0800 (PST)
In-Reply-To: <1417939634-26085-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/7/2014 11:07 AM, Amir Vadai wrote:

> From: Saeed Mahameed <saeedm@mellanox.com>

> Use cmd->autoneg == AUTONEG_DISABLE as a user hint to force specific speed.
> We don't want to rely on ethtool to calculate advertised link modes when
> forcing specific speed, a user can request a specific speed and specify
> "autoneg off" in ethtool command to give a hint for forcing this speed.

> Move en_warn("port reset..") inside the "port reset" block.

> Fixes: d48b3ab ("net/mlx4_en: Use PTYS register to set ethtool settings (Speed)")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index c45e06a..3045582 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -771,13 +771,13 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>   	}
>
>   	proto_admin = cpu_to_be32(ptys_adv);
> -	if (speed >= 0 && speed != priv->port_state.link_speed)
> +	if (speed >= 0 && ((speed != priv->port_state.link_speed) ||
> +			   (cmd->autoneg == AUTONEG_DISABLE)))

    You're using () rather inconsistently. In fact, () around == and != are 
not needed.

[...]

WBR, Sergei
