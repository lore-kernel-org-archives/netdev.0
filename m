From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Correctly handle MII ioctl which changes
 autonegotiation.
Date: Tue, 11 Nov 2014 15:21:46 -0500 (EST)
Message-ID: <20141111.152146.2216423846831865994.davem@davemloft.net>
References: <5462210F.7040306@houston-radar.com>
	<546222F3.7080705@houston-radar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian@houston-radar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaKKUVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:21:48 -0500
In-Reply-To: <546222F3.7080705@houston-radar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Hill <brian@houston-radar.com>
Date: Tue, 11 Nov 2014 07:53:39 -0700

> 
> When advertised capabilities are changed with mii-tool, such as:
> mii-tool -A 10baseT
> the existing handler has two errors.
> 
> - An actual PHY register value is provided by mii-tool, and this
>   must be mapped to internal state with mii_adv_to_ethtool_adv_t().
> - The PHY state machine needs to be told that autonegotiation has
>   again been performed.  If not, the MAC will not be notified of
>   the new link speed and duplex, resulting in a possible config
>   mismatch.
> 
> Signed-off-by: Brian Hill <Brian@houston-radar.com>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy.c |   36 ++++++++++++++++++++++++------------
>  1 file changed, 24 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c94e2a2..ee9f0c9 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -352,6 +352,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
>  {
>  	struct mii_ioctl_data *mii_data = if_mii(ifr);
>  	u16 val = mii_data->val_in;
> +	int change_autoneg = 0;

As Florian asked, please use bool/true/false for 'change_autoneg'.
