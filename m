From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: phy: workaround for buggy cable detection by
 LAN8700 after cable plugging
Date: Thu, 13 Aug 2015 10:15:15 -0700
Message-ID: <1439486115.27506.1.camel@perches.com>
References: <1439471556-13760-1-git-send-email-plyatov@gmail.com>
	 <1439484648.4818.13.camel@perches.com> <55CCCFDF.3090408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@KARO-electronics.de, Frank.Li@freescale.com
To: plyatov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CCCFDF.3090408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-13 at 20:11 +0300, Igor Plyatov wrote:
> > On Thu, 2015-08-13 at 16:12 +0300, Igor Plyatov wrote:
> >> * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
> >>    Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
> >>    set, the ENERGYON bit does not asserted sometimes). This is a common bug of
> >>    LAN87xx family of PHY chips.
> >> * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
> >>    algorythm still not reliable on 100 % and sometimes skip cable plugging.
> > []
> >> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> > []
> >> @@ -104,10 +104,12 @@ static int lan911x_config_init(struct phy_device *phydev)
> >>   static int lan87xx_read_status(struct phy_device *phydev)
> >>   {
> >>   	int err = genphy_read_status(phydev);
> >> +	int rc;
> > Is there a reason to move this declaration?
> 
> There is no strict requirement to move declaration of the rc.
> It was made just to have all declarations easily visible.

Generally it's better to have declarations
in the minimal/narrowest scope possible.
