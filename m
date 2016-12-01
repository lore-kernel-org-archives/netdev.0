From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: simplify flag assignment
Date: Thu, 01 Dec 2016 15:23:03 -0500 (EST)
Message-ID: <20161201.152303.425589678238707778.davem@davemloft.net>
References: <20161124085506.GA25007@amd>
        <20161124.110416.198867271899443489.davem@davemloft.net>
        <20161130114431.GB14296@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130114431.GB14296@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Wed, 30 Nov 2016 12:44:31 +0100

> 
> Simplify flag assignment.
>     
> Signed-off-by: Pavel Machek <pavel@denx.de>
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index ed20668..0b706a7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2771,12 +2771,8 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
>  		features &= ~NETIF_F_CSUM_MASK;
>  
>  	/* Disable tso if asked by ethtool */
> -	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
> -		if (features & NETIF_F_TSO)
> -			priv->tso = true;
> -		else
> -			priv->tso = false;
> -	}
> +	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen))
> +		priv->tso = !!(features & NETIF_F_TSO);
>  

Pavel, this really seems arbitrary.

Whilst I really appreciate you're looking into this driver a bit because
of some issues you are trying to resolve, I'd like to ask that you not
start bombarding me with nit-pick cleanups here and there and instead
concentrate on the real bug or issue.

Thanks in advance.
