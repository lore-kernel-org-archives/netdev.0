From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 1/4] net: phy: utilize phy_suspend and phy_resume
Date: Tue, 27 Jan 2015 02:42:26 +0000
Message-ID: <BLUPR03MB3732890B34D9E7568D7C363F5320@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
 <1422318673-9418-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0135.outbound.protection.outlook.com ([207.46.100.135]:62123
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751116AbbA0Cm2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 21:42:28 -0500
In-Reply-To: <1422318673-9418-2-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com> Sent: Tuesday, January 27, 2015 8:31 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; s.hauer@pengutronix.de; Duan Fugang-B38611;
> Florian Fainelli
> Subject: [PATCH net-next 1/4] net: phy: utilize phy_suspend and
> phy_resume
> 
> phy_suspend and phy_resume are an abstraction on top of the PHY device
> driver suspend and resume callbacks, utilize those since they are the
> proper interface to suspending and resuming a PHY device.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/mdio_bus.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 50051f271b10..20447741893a 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -465,7 +465,6 @@ static bool mdio_bus_phy_may_suspend(struct
> phy_device *phydev)
> 
>  static int mdio_bus_suspend(struct device *dev)  {
> -	struct phy_driver *phydrv = to_phy_driver(dev->driver);
>  	struct phy_device *phydev = to_phy_device(dev);
> 
>  	/* We must stop the state machine manually, otherwise it stops out
> of @@ -479,19 +478,18 @@ static int mdio_bus_suspend(struct device *dev)
>  	if (!mdio_bus_phy_may_suspend(phydev))
>  		return 0;
> 
> -	return phydrv->suspend(phydev);
> +	return phy_suspend(phydev);
>  }
> 
>  static int mdio_bus_resume(struct device *dev)  {
> -	struct phy_driver *phydrv = to_phy_driver(dev->driver);
>  	struct phy_device *phydev = to_phy_device(dev);
>  	int ret;
> 
>  	if (!mdio_bus_phy_may_suspend(phydev))
>  		goto no_resume;
> 
> -	ret = phydrv->resume(phydev);
> +	ret = phy_resume(phydev);
>  	if (ret < 0)
>  		return ret;
> 
> --
> 2.1.0

Test on i.MX6q sabresd board, works fine.

Acked-by: Fugang Duan <B38611@freescale.com>
Tested-by: Fugang Duan <B38611@freescale.com>
