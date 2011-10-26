From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] stmmac: fix NULL pointer dereference in
 capabilities fixup
Date: Thu, 27 Oct 2011 00:26:48 +0200
Message-ID: <1319668008.6759.2.camel@deadeye>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
	 <1319637339-14866-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <keguang.zhang@gmail.com>,
	Angus Clark <angus.clark@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33541 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab1JZW1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 18:27:05 -0400
In-Reply-To: <1319637339-14866-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-26 at 15:55 +0200, Giuseppe CAVALLARO wrote:
> From: Angus Clark <angus.clark@st.com>
> 
> Signed-off-by: Angus Clark <angus.clark@st.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index fcdd5a2..f77eaa6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -325,7 +325,7 @@ static int stmmac_init_phy(struct net_device *dev)
>  	    (interface == PHY_INTERFACE_MODE_RMII))) {
>  		phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
>  				      SUPPORTED_Asym_Pause);
> -		priv->phydev->advertising = priv->phydev->supported;
> +		priv->phydev->advertising = phydev->supported;

How can this fix the bug?  You mean:

		phydev->advertising = phydev->supported;

Ben.

>  	}
>  
>  	/*

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
