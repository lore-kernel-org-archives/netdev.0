From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 net] ravb: unmap descriptors when freeing rings
Date: Thu, 26 Jan 2017 19:48:30 +0300
Message-ID: <ebfc2f11-8fd8-a04e-c480-0ed9eac3fa79@cogentembedded.com>
References: <1485437367-3245-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1485437367-3245-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2017 04:29 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

    Well, Kazuya's patch is so far from your now, you could have said it was 
reported by him or that your patch is loosely based on his one. :-)

> "swiotlb buffer is full" errors occur after repeated initialisation of a
> device - f.e. suspend/resume or ip link set up/down. This is because memory
> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> is not released.  Resolve this problem by unmapping descriptors when
> freeing rings.
>
> Fixes: c156633f1353 ("Renesas Ethernet AVB driver proper")
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> --

    --- is needed here...

> ---

    ... unlike this place. :-)

>  drivers/net/ethernet/renesas/ravb_main.c | 112 ++++++++++++++++++-------------
>  1 file changed, 64 insertions(+), 48 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 89ac1e3f6175..301f48755093 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -179,6 +179,49 @@ static struct mdiobb_ops bb_ops = {
>  	.get_mdio_data = ravb_get_mdio_data,
>  };
>
> +/* Free TX skb function for AVB-IP */
> +static int ravb_tx_free(struct net_device *ndev, int q, bool free_txed_only)

    I'd have called the last parameter just 'all' or at least would have 
avoided such verbs as 'txed'... :-)

> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &priv->stats[q];
> +	struct ravb_tx_desc *desc;
> +	int free_num = 0;
> +	int entry;
> +	u32 size;
> +
> +	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> +		bool txed;

     I'd have declared this in the function scope like all other local vars.
And would have chosen somewhat clearer name, like 'sent'. :-)

[...]

MBR, Sergei
