From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH v2] Move the definition of pr_err() into kernel.h
Date: Tue, 11 Sep 2007 12:48:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903925779@orsmsx414.amr.corp.intel.com>
References: <11895344211267-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Emil Medve" <Emilian.Medve@Freescale.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<i2c@lm-sensors.org>, <linux-omap-open-source@linux.omap.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760773AbXIKTsc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 15:48:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <11895344211267-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Other pr_*() macros are already defined in kernel.h, but 
> pr_err() was defined multiple times in several other places
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> I'm writing a driver and I've been using the pr_*() macros 
> from kernel.h and I was surprised not to find there pr_err() 
> but defined multiple times (in four different files). I 
> didn't want to define it yet one more time so I did this cleanup
> 
> This patch is against Linus' tree v2.6.23-rc6 
> (0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01)
> 
> linux-2.6> scripts/checkpatch.pl 
> 0001-Move-the-definition-of-pr_err-into-kernel.h.patch
> Your patch has no obvious style problems and is ready for submission.

Almost.  :-)

> 
>  drivers/i2c/chips/menelaus.c     |   10 ++++------
>  drivers/net/spider_net.h         |    3 ---
>  drivers/video/omap/lcd_h3.c      |    6 ++----
>  drivers/video/omap/lcd_inn1610.c |    6 ++----
>  include/linux/kernel.h           |    2 ++
>  5 files changed, 10 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/i2c/chips/menelaus.c 
> b/drivers/i2c/chips/menelaus.c index d9c92c5..66436ba 100644
> --- a/drivers/i2c/chips/menelaus.c
> +++ b/drivers/i2c/chips/menelaus.c
> @@ -49,8 +49,6 @@
>  
>  #define DRIVER_NAME			"menelaus"
>  
> -#define pr_err(fmt, arg...)	printk(KERN_ERR DRIVER_NAME ": 
> ", ## arg);
> -

Unnecessary whitespace removal.

>  #define MENELAUS_I2C_ADDRESS		0x72
>  
>  #define MENELAUS_REV			0x01
> @@ -155,7 +153,7 @@ static int menelaus_write_reg(int reg, u8 value)
>  	int val = 
> i2c_smbus_write_byte_data(the_menelaus->client, reg, value);
>  
>  	if (val < 0) {
> -		pr_err("write error");
> +		pr_err(DRIVER_NAME ": write error");
>  		return val;
>  	}
>  
> @@ -167,7 +165,7 @@ static int menelaus_read_reg(int reg)
>  	int val = i2c_smbus_read_byte_data(the_menelaus->client, reg);
>  
>  	if (val < 0)
> -		pr_err("read error");
> +		pr_err(DRIVER_NAME ": read error");
>  
>  	return val;
>  }
> @@ -1177,7 +1175,7 @@ static int menelaus_probe(struct 
> i2c_client *client)
>  	/* If a true probe check the device */
>  	rev = menelaus_read_reg(MENELAUS_REV);
>  	if (rev < 0) {
> -		pr_err("device not found");
> +		pr_err(DRIVER_NAME ": device not found");
>  		err = -ENODEV;
>  		goto fail1;
>  	}
> @@ -1258,7 +1256,7 @@ static int __init menelaus_init(void)
>  
>  	res = i2c_add_driver(&menelaus_i2c_driver);
>  	if (res < 0) {
> -		pr_err("driver registration failed\n");
> +		pr_err(DRIVER_NAME ": driver registration failed\n");
>  		return res;
>  	}
>  
> diff --git a/drivers/net/spider_net.h 
> b/drivers/net/spider_net.h index dbbdb8c..c67b11d 100644
> --- a/drivers/net/spider_net.h
> +++ b/drivers/net/spider_net.h
> @@ -493,7 +493,4 @@ struct spider_net_card {
>  	struct spider_net_descr darray[0];
>  };
>  
> -#define pr_err(fmt,arg...) \
> -	printk(KERN_ERR fmt ,##arg)
> -

Unnecessary whitespace removal.

>  #endif
> diff --git a/drivers/video/omap/lcd_h3.c 
> b/drivers/video/omap/lcd_h3.c index 51807b4..c604d93 100644
> --- a/drivers/video/omap/lcd_h3.c
> +++ b/drivers/video/omap/lcd_h3.c
> @@ -28,8 +28,6 @@
>  
>  #define MODULE_NAME	"omapfb-lcd_h3"
>  
> -#define pr_err(fmt, args...) printk(KERN_ERR MODULE_NAME ": 
> " fmt, ## args)
> -

Unnecessary whitespace removal.

>  static int h3_panel_init(struct lcd_panel *panel, struct 
> omapfb_device *fbdev)  {
>  	return 0;
> @@ -48,7 +46,7 @@ static int h3_panel_enable(struct lcd_panel *panel)
>  	if (!r)
>  		r = tps65010_set_gpio_out_value(GPIO2, HIGH);
>  	if (r)
> -		pr_err("Unable to turn on LCD panel\n");
> +		pr_err(MODULE_NAME ": Unable to turn on LCD panel\n");
>  
>  	return r;
>  }
> @@ -62,7 +60,7 @@ static void h3_panel_disable(struct 
> lcd_panel *panel)
>  	if (!r)
>  		tps65010_set_gpio_out_value(GPIO2, LOW);
>  	if (r)
> -		pr_err("Unable to turn off LCD panel\n");
> +		pr_err(MODULE_NAME ": Unable to turn off LCD panel\n");
>  }
>  
>  static unsigned long h3_panel_get_caps(struct lcd_panel 
> *panel) diff --git a/drivers/video/omap/lcd_inn1610.c 
> b/drivers/video/omap/lcd_inn1610.c
> index 95604ca..5ef119c 100644
> --- a/drivers/video/omap/lcd_inn1610.c
> +++ b/drivers/video/omap/lcd_inn1610.c
> @@ -27,20 +27,18 @@
>  
>  #define MODULE_NAME	"omapfb-lcd_h3"
>  
> -#define pr_err(fmt, args...) printk(KERN_ERR MODULE_NAME ": 
> " fmt, ## args)
> -

Unnecessary whitespace removal.

>  static int innovator1610_panel_init(struct lcd_panel *panel,
>  				    struct omapfb_device *fbdev)
>  {
>  	int r = 0;
>  
>  	if (omap_request_gpio(14)) {
> -		pr_err("can't request GPIO 14\n");
> +		pr_err(MODULE_NAME ": can't request GPIO 14\n");
>  		r = -1;
>  		goto exit;
>  	}
>  	if (omap_request_gpio(15)) {
> -		pr_err("can't request GPIO 15\n");
> +		pr_err(MODULE_NAME ": can't request GPIO 15\n");
>  		omap_free_gpio(14);
>  		r = -1;
>  		goto exit;
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h 
> index f592df7..c51936a 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -242,6 +242,8 @@ static inline int __attribute__ ((format 
> (printf, 1, 2))) pr_debug(const char *
>  
>  #define pr_info(fmt,arg...) \
>  	printk(KERN_INFO fmt,##arg)
> +#define pr_err(fmt, arg...) \
> +	printk(KERN_ERR fmt, ##arg)
>  
>  /*
>   *      Display an IP address in readable format.
> --
> 1.5.3.GIT

Cheers,

-PJ Waskiewicz
Intel Corp.
peter.p.waskiewicz.jr@intel.com
