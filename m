From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/4] net-next: stmmac: Convert new_state to bool
Date: Mon, 22 May 2017 06:07:43 -0700
Message-ID: <1495458463.2093.17.camel@perches.com>
References: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
         <20170522123347.5295-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0105.hostedemail.com ([216.40.44.105]:55895 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751312AbdEVNHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 09:07:47 -0400
In-Reply-To: <20170522123347.5295-2-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-22 at 14:33 +0200, Corentin Labbe wrote:
> This patch convert new_state from int to bool since it store only 1 or 0
[]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[]
> @@ -849,11 +849,11 @@ static void stmmac_adjust_link(struct net_device *dev)
>  		writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
>  
>  		if (!priv->oldlink) {
> -			new_state = 1;
> +			new_state = true;
>  			priv->oldlink = 1;
>  		}
>  	} else if (priv->oldlink) {
> -		new_state = 1;
> +		new_state = true;
>  		priv->oldlink = 0;
>  		priv->speed = SPEED_UNKNOWN;
>  		priv->oldduplex = DUPLEX_UNKNOWN;

It seems oldlink could be bool as well.

drivers/net/ethernet/stmicro/stmmac/stmmac.h:   int oldlink;
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:              if (!priv->oldlink) {
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:                      priv->oldlink = 1;
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:      } else if (priv->oldlink) {
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:              priv->oldlink = 0;
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:      priv->oldlink = 0;
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:      priv->oldlink = 0;
