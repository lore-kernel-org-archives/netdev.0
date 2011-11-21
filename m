From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH 1/1]  PHY configuration for compatible issue
Date: Mon, 21 Nov 2011 13:35:06 +0800
Message-ID: <20111121053026.M38786@cooldavid.org>
References: <1321870127-15541-1-git-send-email-AriesLee@jmicron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
To: AriesLee <AriesLee@jmicron.com>,
	Aries Lee <ariesleeILan@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:59805 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862Ab1KUFfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 00:35:14 -0500
In-Reply-To: <1321870127-15541-1-git-send-email-AriesLee@jmicron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2011 18:08:47 +0800, AriesLee wrote
> To perform PHY calibration and set a different EA value by chip ID,
> Whenever the NIC chip power on, ie booting or resuming, we need to
> force HW to calibrate PHY parameter again, and also set a proper EA
> value which gather from experiment.
> 
> Those procedures help to reduce compatible issues(NIC is unable to link
> up in some special case) in giga speed.
> 
> Signed-off-by: AriesLee <AriesLee@jmicron.com>
> ---
>  drivers/net/ethernet/jme.c |  113 
> ++++++++++++++++++++++++++++++++++++++++++- drivers/net/ethernet/jme.h 
> |   19 +++++++ 2 files changed, 129 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
> index df3ab83..4d217b8 100644
> --- a/drivers/net/ethernet/jme.c
> +++ b/drivers/net/ethernet/jme.c
> @@ -1744,6 +1744,112 @@ jme_phy_off(struct jme_adapter *jme)
>  		jme_new_phy_off(jme);
>  }
> 
> +static void
> +jme_phy_specreg_read(struct jme_adapter *jme, u32 specreg, u32 *phy_data) 
> +{
> +	u32 phy_addr;
> +
> +	phy_addr = JM_PHY_SPEC_REG_READ | specreg;
> +	jme_mdio_write(jme->dev, jme->mii_if.phy_id, JM_PHY_SPEC_ADDR_REG,
> +			phy_addr);
> +	*phy_data = jme_mdio_read(jme->dev, jme->mii_if.phy_id,
> +			JM_PHY_SPEC_DATA_REG);
> +}
Is there any particular reason that you pass the address of reading data.
Instead of just returning the value? (phy_data)
It would be more consistent if you return the value in this kind of
read function.

Otherwise this path all seems to be OK to me. :)

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Guo-Fu Tseng
