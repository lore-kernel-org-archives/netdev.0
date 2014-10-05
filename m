From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 14/14] net/mlx4_en: Use the new tx_copybreak
 to set inline threshold
Date: Sun, 05 Oct 2014 17:03:40 +0400
Message-ID: <543141AC.3060006@cogentembedded.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com> <1412501722-25092-15-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34293 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaJENDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 09:03:43 -0400
Received: by mail-lb0-f180.google.com with SMTP id f15so2976773lbj.39
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 06:03:41 -0700 (PDT)
In-Reply-To: <1412501722-25092-15-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/5/2014 1:35 PM, Amir Vadai wrote:

> From: Eric Dumazet <edumazet@google.com>

> Instead of setting inline threshold using module parameter only on
> driver load, use set_tunable() to set it dynamically.
> No need to store the threshold per ring, using instead the netdev global
> priv->prof->inline_thold
> Initial value still is set using the module parameter, therefore
> backward compatability is kept.

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 44 +++++++++++++++++++++++++
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  1 -
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 -
>   3 files changed, 44 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 42c9f8b..ae83da9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
[...]
> @@ -1297,6 +1339,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
>   	.get_ts_info = mlx4_en_get_ts_info,
>   	.set_priv_flags = mlx4_en_set_priv_flags,
>   	.get_priv_flags = mlx4_en_get_priv_flags,
> +	.get_tunable		= mlx4_en_get_tunable,
> +	.set_tunable		= mlx4_en_set_tunable,

    If the above initializers aren't aligned with tabs, why should these two be?

WBR, Sergei
