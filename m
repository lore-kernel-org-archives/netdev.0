From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH][V2] net: stmmac: ensure jumbo_frm error return is
 correctly checked for -ve value
Date: Mon, 5 Jun 2017 11:20:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1706051119210.2010@hadrien>
References: <20170605090452.30688-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170605090452.30688-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 5 Jun 2017, Colin King wrote:

> From: Colin Ian King <colin.king@canonical.com>
>
> The current comparison of entry < 0 will never be true since entry is an
> unsigned integer. Make entry an int to ensure -ve error return values
> from the call to jumbo_frm are correctly being caught.

Perhaps it would be good to mention that the return value of jumbo_frm
is an int and that the subsequent computations on entry are all on small
values so there is no need for unsigned.

julia

>
> Detected by CoverityScan, CID#1238760 ("Macro compares unsigned to 0")
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 68a188e74c54..3346a99ce4c4 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2945,7 +2945,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int i, csum_insertion = 0, is_jumbo = 0;
>  	u32 queue = skb_get_queue_mapping(skb);
>  	int nfrags = skb_shinfo(skb)->nr_frags;
> -	unsigned int entry, first_entry;
> +	int entry;
> +	unsigned int first_entry;
>  	struct dma_desc *desc, *first;
>  	struct stmmac_tx_queue *tx_q;
>  	unsigned int enh_desc;
> --
> 2.11.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
