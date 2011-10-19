From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] smsc911x: Enable flow control advertisement
Date: Wed, 19 Oct 2011 13:26:39 +0100
Message-ID: <1319027199.23980.47.camel@deadeye>
References: <1319016114-4781-1-git-send-email-kkobayas@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	dhobsong@igel.co.jp
To: Kazunori Kobayashi <kkobayas@igel.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50166 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab1JSM0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 08:26:51 -0400
In-Reply-To: <1319016114-4781-1-git-send-email-kkobayas@igel.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 18:21 +0900, Kazunori Kobayashi wrote:
> Enable the advertisement of both symmetric pause and asymmetric pause 
> flow control capability. 
> 
> Signed-off-by: Kazunori Kobayashi <kkobayas@igel.co.jp>
> ---
>  drivers/net/smsc911x.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index b9016a3..60c3bc2 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c

This file has been moved.

> @@ -800,8 +800,13 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
>  	struct phy_device *phy_dev = pdata->phy_dev;
>  	u32 afc = smsc911x_reg_read(pdata, AFC_CFG);
>  	u32 flow;
> +	u16 miiadv = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
> +				       MII_ADVERTISE);
>  	unsigned long flags;
>  
> +	miiadv |= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
> +	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_ADVERTISE, miiadv);

This should be controllable through ethtool; I assume phy_ethtool_sset()
already covers that.

Further, it's far too late to change advertising when you're just about
to resolve what was negotiated.  It has to be done before (re)starting
autoneg.

Ben.

>  	if (phy_dev->duplex == DUPLEX_FULL) {
>  		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
>  		u16 rmtadv = phy_read(phy_dev, MII_LPA);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
