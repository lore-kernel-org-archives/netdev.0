From: Michael =?ISO-8859-1?Q?B=FCsch?= <mb@bu3sch.de>
Subject: Re: [PATCH] ssb: Add sysfs attributes to ssb devices
Date: Mon, 29 Nov 2010 23:19:32 +0100
Message-ID: <1291069172.14734.0.camel@maggie>
References: <1290943372-27749-1-git-send-email-hauke@hauke-m.de>
	 (sfid-20101128_122307_977986_373C776B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Bernhard Loos <bernhardloos@googlemail.com>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 80-190-117-144.ip-home.de ([80.190.117.144]:58441 "EHLO
	bu3sch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab0K2WTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 17:19:39 -0500
In-Reply-To: <1290943372-27749-1-git-send-email-hauke@hauke-m.de> (sfid-20101128_122307_977986_373C776B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-28 at 12:22 +0100, Hauke Mehrtens wrote: 
> Make it possible to read out the attributes, till now only show on
> dmesg, through sysfs.
> 
> This patch was some time in OpenWrt.
> 
> Signed-off-by: Bernhard Loos <bernhardloos@googlemail.com>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Michael Buesch <mb@bu3sch.de>

> ---
>  drivers/ssb/main.c |   30 ++++++++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> index c68b3dc..3918d2c 100644
> --- a/drivers/ssb/main.c
> +++ b/drivers/ssb/main.c
> @@ -383,6 +383,35 @@ static int ssb_device_uevent(struct device *dev, struct kobj_uevent_env *env)
>  			     ssb_dev->id.revision);
>  }
>  
> +#define ssb_config_attr(attrib, field, format_string) \
> +static ssize_t \
> +attrib##_show(struct device *dev, struct device_attribute *attr, char *buf) \
> +{ \
> +	return sprintf(buf, format_string, dev_to_ssb_dev(dev)->field); \
> +}
> +
> +ssb_config_attr(core_num, core_index, "%u\n")
> +ssb_config_attr(coreid, id.coreid, "0x%04x\n")
> +ssb_config_attr(vendor, id.vendor, "0x%04x\n")
> +ssb_config_attr(revision, id.revision, "%u\n")
> +ssb_config_attr(irq, irq, "%u\n")
> +static ssize_t
> +name_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%s\n",
> +		       ssb_core_name(dev_to_ssb_dev(dev)->id.coreid));
> +}
> +
> +static struct device_attribute ssb_device_attrs[] = {
> +	__ATTR_RO(name),
> +	__ATTR_RO(core_num),
> +	__ATTR_RO(coreid),
> +	__ATTR_RO(vendor),
> +	__ATTR_RO(revision),
> +	__ATTR_RO(irq),
> +	__ATTR_NULL,
> +};
> +
>  static struct bus_type ssb_bustype = {
>  	.name		= "ssb",
>  	.match		= ssb_bus_match,
> @@ -392,6 +421,7 @@ static struct bus_type ssb_bustype = {
>  	.suspend	= ssb_device_suspend,
>  	.resume		= ssb_device_resume,
>  	.uevent		= ssb_device_uevent,
> +	.dev_attrs	= ssb_device_attrs,
>  };
>  
>  static void ssb_buses_lock(void)


-- 
Greetings Michael.

