From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: Add handling for
 RGMII_ID/RXID/TXID
Date: Wed, 22 Mar 2017 19:32:41 -0700 (PDT)
Message-ID: <20170322.193241.552898718641680618.davem@davemloft.net>
References: <1490197822-35428-1-git-send-email-w.egorov@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rockchip@lists.infradead.org
To: w.egorov@phytec.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdCWCcn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:32:43 -0400
In-Reply-To: <1490197822-35428-1-git-send-email-w.egorov@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wadim Egorov <w.egorov@phytec.de>
Date: Wed, 22 Mar 2017 16:50:22 +0100

> @@ -74,6 +74,10 @@ struct rk_priv_data {
>  #define GRF_BIT(nr)	(BIT(nr) | BIT(nr+16))
>  #define GRF_CLR_BIT(nr)	(BIT(nr+16))
>  
> +#define DELAY_ENABLE(soc, tx, rx) \
> +	((tx) ? soc##_GMAC_TXCLK_DLY_ENABLE : soc##_GMAC_TXCLK_DLY_DISABLE | \
> +	 (rx) ? soc##_GMAC_RXCLK_DLY_ENABLE : soc##_GMAC_RXCLK_DLY_DISABLE)

This doesn't evaluate the way you want it to.

You need to put parenthesis around both "x ? a : b" expressions.
