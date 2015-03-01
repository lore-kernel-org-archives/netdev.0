From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/2] net/mlx4_en: Disbale GRO for incoming loopback/selftest
 packets
Date: Sun, 01 Mar 2015 20:24:06 +0300
Message-ID: <54F34B36.2010202@cogentembedded.com>
References: <1425221774-8874-1-git-send-email-ogerlitz@mellanox.com> <1425221774-8874-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:42045 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbCARYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 12:24:09 -0500
Received: by lamq1 with SMTP id q1so2925629lam.9
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 09:24:07 -0800 (PST)
In-Reply-To: <1425221774-8874-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/1/2015 5:56 PM, Or Gerlitz wrote:

> From: Ido Shamay <idos@mellanox.com>

> Packets which are sent from the selftest (ethtool) flow, should not
> be passed to the GRO stack but rather dropped by the driver after validation.
> To achieve that, we disable GRO for the duration of the selftest.

> Fixes: dd65beac48a5 ("net/mlx4_en: Extend usage of napi_gro_frags")
> Reported-by: Carol Soto <clsoto@linux.vnet.ibm.com>
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_selftest.c |    8 +++++++-
>   1 files changed, 7 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
> index 2d8ee66..ac8870c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
> @@ -81,12 +81,14 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
>   {
>   	u32 loopback_ok = 0;
>   	int i;
> -
> +	bool gro_enabled;
>
>           priv->loopback_ok = 0;
>   	priv->validate_loopback = 1;
> +	gro_enabled = (priv->dev->features & NETIF_F_GRO);

    Parens not necessary here.

[...]

WBR, Sergei
