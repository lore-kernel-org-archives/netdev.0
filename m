From: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 5/5] net: rfkill: gpio: remove rfkill_gpio_platform_data
Date: Thu, 6 Aug 2015 10:22:14 +0300
Message-ID: <20150806072214.GG7675@kuha.fi.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1438781947-7952-6-git-send-email-heikki.krogerus@linux.intel.com>
 <1438784128.29746.177.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1438784128.29746.177.camel-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 05:15:28PM +0300, Andy Shevchenko wrote:
> On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:
> > No more users for it.
> > 
> > Signed-off-by: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > ---
> >  include/linux/rfkill-gpio.h | 37 -----------------------------------
> > --
> >  net/rfkill/Kconfig          |  3 +--
> >  net/rfkill/rfkill-gpio.c    |  8 --------
> >  3 files changed, 1 insertion(+), 47 deletions(-)
> >  delete mode 100644 include/linux/rfkill-gpio.h
> > 
> > diff --git a/include/linux/rfkill-gpio.h b/include/linux/rfkill
> > -gpio.h
> > deleted file mode 100644
> > index 20bcb55..0000000
> > --- a/include/linux/rfkill-gpio.h
> > +++ /dev/null
> > @@ -1,37 +0,0 @@
> > -/*
> > - * Copyright (c) 2011, NVIDIA Corporation.
> > - *
> > - * This program is free software; you can redistribute it and/or 
> > modify
> > - * it under the terms of the GNU General Public License as published 
> > by
> > - * the Free Software Foundation; either version 2 of the License, or
> > - * (at your option) any later version.
> > - *
> > - * This program is distributed in the hope that it will be useful, 
> > but WITHOUT
> > - * ANY WARRANTY; without even the implied warranty of 
> > MERCHANTABILITY or
> > - * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public 
> > License for
> > - * more details.
> > - *
> > - * You should have received a copy of the GNU General Public License 
> > along
> > - * with this program; if not, write to the Free Software Foundation, 
> > Inc.,
> > - * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
> > - */
> > -
> > -
> > -#ifndef __RFKILL_GPIO_H
> > -#define __RFKILL_GPIO_H
> > -
> > -#include <linux/types.h>
> > -#include <linux/rfkill.h>
> > -
> > -/**
> > - * struct rfkill_gpio_platform_data - platform data for rfkill gpio 
> > device.
> > - * for unused gpio's, the expected value is -1.
> > - * @name:		name for the gpio rf kill instance
> > - */
> > -
> > -struct rfkill_gpio_platform_data {
> > -	char			*name;
> > -	enum rfkill_type	type;
> > -};
> > -
> > -#endif /* __RFKILL_GPIO_H */
> > diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
> > index 4c10e7e..6320890 100644
> > --- a/net/rfkill/Kconfig
> > +++ b/net/rfkill/Kconfig
> > @@ -40,5 +40,4 @@ config RFKILL_GPIO
> >  	default n
> >  	help
> >  	  If you say yes here you get support of a generic gpio 
> > RFKILL
> > -	  driver. The platform should fill in the appropriate fields 
> > in the
> > -	  rfkill_gpio_platform_data structure and pass that to the 
> > driver.
> > +	  driver.
> > diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> > index 07323c3..69d92e1 100644
> > --- a/net/rfkill/rfkill-gpio.c
> > +++ b/net/rfkill/rfkill-gpio.c
> > @@ -27,8 +27,6 @@
> >  #include <linux/acpi.h>
> >  #include <linux/gpio/consumer.h>
> >  
> > -#include <linux/rfkill-gpio.h>
> > -
> >  struct rfkill_gpio_data {
> >  	const char		*name;
> >  	enum rfkill_type	type;
> > @@ -89,7 +87,6 @@ static int rfkill_gpio_acpi_probe(struct device 
> > *dev,
> >  
> >  static int rfkill_gpio_probe(struct platform_device *pdev)
> >  {
> > -	struct rfkill_gpio_platform_data *pdata = pdev
> > ->dev.platform_data;
> >  	struct rfkill_gpio_data *rfkill;
> >  	struct gpio_desc *gpio;
> >  	const char *type_name;
> > @@ -111,11 +108,6 @@ static int rfkill_gpio_probe(struct 
> > platform_device *pdev)
> >  		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
> >  		if (ret)
> >  			return ret;
> > -	} else if (pdata) {
> > -		rfkill->name = pdata->name;
> > -		rfkill->type = pdata->type;
> > -	} else {
> > -		return -ENODEV;
> 
> Shouldn't we leave the error path and modify to check if we have device
> property set set?

We already check them before this point. After this ACPI will be the
only "special" case where we know the needed information does not come
from device property and needs separate handling. Otherwise, if the
device properties are not set, we cracefully fail.


Thanks,

-- 
heikki
