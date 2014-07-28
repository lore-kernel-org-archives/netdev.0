From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Copy exact header to SKB linear
 part
Date: Mon, 28 Jul 2014 14:56:46 +0400
Message-ID: <53D62C6E.7050604@cogentembedded.com>
References: <1406542451-8857-1-git-send-email-amirv@mellanox.com> <1406542451-8857-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:54863 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaG1K4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 06:56:49 -0400
Received: by mail-lb0-f180.google.com with SMTP id v6so5574622lbi.39
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 03:56:46 -0700 (PDT)
In-Reply-To: <1406542451-8857-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/28/2014 02:14 PM, Amir Vadai wrote:

> Based on patch from Eric Dumazet
> When copy received packet header to the linear section of the SKB,

    s/copy/copying/.

> Copy the exact header (best effort) and not the max possible header,

    s/Copy/copy/.

> using the new network helper function __net_get_headlen.

    Not eth_frame_headlen()?

> It will return the size of the header up to the latest known header.

> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c | 13 ++++++++-----
>   1 file changed, 8 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 9c909d2..c4471f1 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -588,6 +588,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
>   		skb_copy_to_linear_data(skb, va, length);
>   		skb->tail += length;
>   	} else {
> +		unsigned int hlen;

    Empty line needed here.

>   		/* Move relevant fragments to skb */
>   		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
>   							skb, length);

WBR, Sergei
