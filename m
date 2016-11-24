From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] stmmac ethernet: remove cut & paste code
Date: Thu, 24 Nov 2016 12:05:25 -0800
Message-ID: <1480017925.19726.13.camel@perches.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
         <20161124102901.GA27793@amd> <20161124103630.GB27793@amd>
         <20161124104619.GA30723@amd> <20161124110548.GB30723@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>, peppe.cavallaro@st.com,
        netdev@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124110548.GB30723@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-11-24 at 12:05 +0100, Pavel Machek wrote:
> Remove duplicate code from _tx routines.

trivia:

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[]
> @@ -1960,6 +1960,38 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
>  	}
>  }
>  
> +static void stmmac_xmit_common(struct sk_buff *skb, struct net_device *dev, int nfrags, struct dma_desc *desc)
> +{
> +	struct stmmac_priv *priv = netdev_priv(dev);
> +
> +	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
> +		if (netif_msg_hw(priv))
> +			pr_debug("%s: stop transmitted packets\n", __func__);

		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
			  __func__);
