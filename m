From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH v3] Make the pr_*() family of macros in kernel.h complete
Date: Fri, 14 Sep 2007 06:27:04 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E270155578C@az33exm24.fsl.freescale.net>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<i2c@lm-sensors.org>, <linux-omap-open-source@linux.omap.com>
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932074AbXINN1Y@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Andrew,


I realize this e-mail might be nuisance and time waster for you but I'm
in need of advice. I apologize in advance for any commonsense cultural
conventions I'm breaking.

I sent the below patch to four e-mail lists and it lead to orthogonal
conversations about how the entire kernel logging system/mechanisms need
to be re-written and thus such incremental improvements as these get out
of focus...

In this case I started needing pr_err() and discovered that is defined
already four times but not with global visibility as some other pr_*()
from kernel.h (a subset of the entire family). I chose not to define it
yet the fifth time but clean up the existing definitions and complete
the family. For some reason it didn't go through even though I had some
positive feedback. Now it seems I'm encouraged to really define the
pr_err() for the fifth time...  Not quite sure what to do...


Cheers,
Emil.


> -----Original Message-----
> From: Medve Emilian-EMMEDVE1 
> Sent: Wednesday, September 12, 2007 11:40 AM
> To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; 
> i2c@lm-sensors.org; linux-omap-open-source@linux.omap.com
> Cc: Medve Emilian-EMMEDVE1
> Subject: [PATCH v3] Make the pr_*() family of macros in 
> kernel.h complete
> 
> Other/Some pr_*() macros are already defined in kernel.h, but 
> pr_err() was defined
> multiple times in several other places
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> I'm writing a driver and I've been using the pr_*() macros 
> from kernel.h and I
> was surprised not to find there pr_err() but defined multiple 
> times (in four
> different files). I didn't want to define it yet one more 
> time so I did this
> cleanup
> 
> As per community request/suggestion, I added the rest of the 
> missing pr_*()
> macros to complete the family. The names of the macros are 
> based on the KERN_*
> loglevel names and are macthing the naming convention of the 
> dev_*() print
> macros from device.h. The macros are defined in the ascending 
> order of the
> loglevel
> 
> This patch is against Linus' tree 
> (577107e8e4cf9f6f4f5ef8350ac9a8faa6c3796d)
> 
> linux-2.6> scripts/checkpatch.pl 
> 0001-Make-the-pr_-family-of-macros-in-kernel.h-complet.patch 
> Your patch has no obvious style problems and is ready for submission.
> 
>  drivers/i2c/chips/menelaus.c     |   10 ++++------
>  drivers/net/spider_net.h         |    3 ---
>  drivers/video/omap/lcd_h3.c      |    6 ++----
>  drivers/video/omap/lcd_inn1610.c |    6 ++----
>  include/linux/kernel.h           |   22 +++++++++++++++++-----
>  5 files changed, 25 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/i2c/chips/menelaus.c 
> b/drivers/i2c/chips/menelaus.c
> index d9c92c5..66436ba 100644
> --- a/drivers/i2c/chips/menelaus.c
> +++ b/drivers/i2c/chips/menelaus.c
> @@ -49,8 +49,6 @@
>  
>  #define DRIVER_NAME			"menelaus"
>  
> -#define pr_err(fmt, arg...)	printk(KERN_ERR DRIVER_NAME ": 
> ", ## arg);
> -
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
> diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
> index dbbdb8c..c67b11d 100644
> --- a/drivers/net/spider_net.h
> +++ b/drivers/net/spider_net.h
> @@ -493,7 +493,4 @@ struct spider_net_card {
>  	struct spider_net_descr darray[0];
>  };
>  
> -#define pr_err(fmt,arg...) \
> -	printk(KERN_ERR fmt ,##arg)
> -
>  #endif
> diff --git a/drivers/video/omap/lcd_h3.c b/drivers/video/omap/lcd_h3.c
> index 51807b4..c604d93 100644
> --- a/drivers/video/omap/lcd_h3.c
> +++ b/drivers/video/omap/lcd_h3.c
> @@ -28,8 +28,6 @@
>  
>  #define MODULE_NAME	"omapfb-lcd_h3"
>  
> -#define pr_err(fmt, args...) printk(KERN_ERR MODULE_NAME ": 
> " fmt, ## args)
> -
>  static int h3_panel_init(struct lcd_panel *panel, struct 
> omapfb_device *fbdev)
>  {
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
>  static unsigned long h3_panel_get_caps(struct lcd_panel *panel)
> diff --git a/drivers/video/omap/lcd_inn1610.c 
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
> index 47160fe..166a822 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -230,10 +230,25 @@ extern void print_hex_dump_bytes(const 
> char *prefix_str, int prefix_type,
>  			const void *buf, size_t len);
>  #define hex_asc(x)	"0123456789abcdef"[x]
>  
> +#define pr_emerg(fmt, arg...) \
> +	printk(KERN_EMERG fmt, ##arg)
> +#define pr_alert(fmt, arg...) \
> +	printk(KERN_ALERT fmt, ##arg)
> +#define pr_crit(fmt, arg...) \
> +	printk(KERN_CRIT fmt, ##arg)
> +#define pr_err(fmt, arg...) \
> +	printk(KERN_ERR fmt, ##arg)
> +#define pr_warning(fmt, arg...) \
> +	printk(KERN_WARNING fmt, ##arg)
> +#define pr_notice(fmt, arg...) \
> +	printk(KERN_NOTICE fmt, ##arg)
> +#define pr_info(fmt, arg...) \
> +	printk(KERN_INFO fmt, ##arg)
> +
>  #ifdef DEBUG
>  /* If you are writing a driver, please use dev_dbg instead */
> -#define pr_debug(fmt,arg...) \
> -	printk(KERN_DEBUG fmt,##arg)
> +#define pr_debug(fmt, arg...) \
> +	printk(KERN_DEBUG fmt, ##arg)
>  #else
>  static inline int __attribute__ ((format (printf, 1, 2))) 
> pr_debug(const char * fmt, ...)
>  {
> @@ -241,9 +256,6 @@ static inline int __attribute__ ((format 
> (printf, 1, 2))) pr_debug(const char *
>  }
>  #endif
>  
> -#define pr_info(fmt,arg...) \
> -	printk(KERN_INFO fmt,##arg)
> -
>  /*
>   *      Display an IP address in readable format.
>   */
> -- 
> 1.5.3.GIT
