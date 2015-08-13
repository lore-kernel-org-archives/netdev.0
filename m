From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: phy: workaround for buggy cable detection by
 LAN8700 after cable plugging
Date: Thu, 13 Aug 2015 09:50:48 -0700
Message-ID: <1439484648.4818.13.camel@perches.com>
References: <1439471556-13760-1-git-send-email-plyatov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@KARO-electronics.de, Frank.Li@freescale.com
To: Igor Plyatov <plyatov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439471556-13760-1-git-send-email-plyatov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-13 at 16:12 +0300, Igor Plyatov wrote:
> * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
>   Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
>   set, the ENERGYON bit does not asserted sometimes). This is a common bug of
>   LAN87xx family of PHY chips.
> * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
>   algorythm still not reliable on 100 % and sometimes skip cable plugging.
[]
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
[]
> @@ -104,10 +104,12 @@ static int lan911x_config_init(struct phy_device *phydev)
>  static int lan87xx_read_status(struct phy_device *phydev)
>  {
>  	int err = genphy_read_status(phydev);
> +	int rc;

Is there a reason to move this declaration?

> +	int i;
>  
>  	if (!phydev->link) {
>  		/* Disable EDPD to wake up PHY */
> -		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> +		rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
>  		if (rc < 0)
>  			return rc;
>  
