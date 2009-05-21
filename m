From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/2] cxgb3: Use generic XENPAK LASI register definitions
Date: Wed, 20 May 2009 18:52:19 -0700
Message-ID: <4A14B3D3.2020701@chelsio.com>
References: <1242775350.3198.10.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24612 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbZEUBwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 21:52:19 -0400
In-Reply-To: <1242775350.3198.10.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>   

Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>  drivers/net/cxgb3/ael1002.c |    3 ++-
>  drivers/net/cxgb3/common.h  |   10 ----------
>  drivers/net/cxgb3/t3_hw.c   |   12 +++++++-----
>  3 files changed, 9 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
> index bebc00d..df1f585 100644
> --- a/drivers/net/cxgb3/ael1002.c
> +++ b/drivers/net/cxgb3/ael1002.c
> @@ -1007,7 +1007,8 @@ static int ael2005_reset(struct cphy *phy, int wait)
>  	int err;
>  	unsigned int lasi_ctrl;
>  
> -	err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_CTRL, &lasi_ctrl);
> +	err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL,
> +			   &lasi_ctrl);
>  	if (err)
>  		return err;
>  
> diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
> index 3147789..79a113b 100644
> --- a/drivers/net/cxgb3/common.h
> +++ b/drivers/net/cxgb3/common.h
> @@ -521,16 +521,6 @@ enum {
>  	MAC_RXFIFO_SIZE = 32768
>  };
>  
> -/* LASI control and status registers */
> -enum {
> -	RX_ALARM_CTRL = 0x9000,
> -	TX_ALARM_CTRL = 0x9001,
> -	LASI_CTRL = 0x9002,
> -	RX_ALARM_STAT = 0x9003,
> -	TX_ALARM_STAT = 0x9004,
> -	LASI_STAT = 0x9005
> -};
> -
>  /* PHY loopback direction */
>  enum {
>  	PHY_LOOPBACK_TX = 1,
> diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
> index c8a865a..505a187 100644
> --- a/drivers/net/cxgb3/t3_hw.c
> +++ b/drivers/net/cxgb3/t3_hw.c
> @@ -472,29 +472,31 @@ int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex)
>  
>  int t3_phy_lasi_intr_enable(struct cphy *phy)
>  {
> -	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, LASI_CTRL, 1);
> +	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL,
> +			     MDIO_PMA_LASI_LSALARM);
>  }
>  
>  int t3_phy_lasi_intr_disable(struct cphy *phy)
>  {
> -	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, LASI_CTRL, 0);
> +	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL, 0);
>  }
>  
>  int t3_phy_lasi_intr_clear(struct cphy *phy)
>  {
>  	u32 val;
>  
> -	return t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_STAT, &val);
> +	return t3_mdio_read(phy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT, &val);
>  }
>  
>  int t3_phy_lasi_intr_handler(struct cphy *phy)
>  {
>  	unsigned int status;
> -	int err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_STAT, &status);
> +	int err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT,
> +			       &status);
>  
>  	if (err)
>  		return err;
> -	return (status & 1) ?  cphy_cause_link_change : 0;
> +	return (status & MDIO_PMA_LASI_LSALARM) ? cphy_cause_link_change : 0;
>  }
>  
>  static const struct adapter_info t3_adap_info[] = {
>
>   

