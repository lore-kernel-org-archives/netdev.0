From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: workaround for buggy cable detection by
 LAN8700 after cable plugging
Date: Thu, 13 Aug 2015 11:37:43 -0700 (PDT)
Message-ID: <20150813.113743.802151188971802087.davem@davemloft.net>
References: <1439484648.4818.13.camel@perches.com>
	<55CCCFDF.3090408@gmail.com>
	<1439486115.27506.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: plyatov@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, f.fainelli@gmail.com,
	luwei.zhou@freescale.com, richardcochran@gmail.com,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@KARO-electronics.de, Frank.Li@freescale.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439486115.27506.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 13 Aug 2015 10:15:15 -0700

> On Thu, 2015-08-13 at 20:11 +0300, Igor Plyatov wrote:
>> > On Thu, 2015-08-13 at 16:12 +0300, Igor Plyatov wrote:
>> >> * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
>> >>    Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
>> >>    set, the ENERGYON bit does not asserted sometimes). This is a common bug of
>> >>    LAN87xx family of PHY chips.
>> >> * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
>> >>    algorythm still not reliable on 100 % and sometimes skip cable plugging.
>> > []
>> >> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
>> > []
>> >> @@ -104,10 +104,12 @@ static int lan911x_config_init(struct phy_device *phydev)
>> >>   static int lan87xx_read_status(struct phy_device *phydev)
>> >>   {
>> >>   	int err = genphy_read_status(phydev);
>> >> +	int rc;
>> > Is there a reason to move this declaration?
>> 
>> There is no strict requirement to move declaration of the rc.
>> It was made just to have all declarations easily visible.
> 
> Generally it's better to have declarations
> in the minimal/narrowest scope possible.

Agreed, and it's %100 unrelated to the purpose of this patch so not
should be included for that reason as well.

You will need to respin this patch with the variable moving elided.
