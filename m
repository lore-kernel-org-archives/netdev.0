From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4 2/4] NET ethernet introduce mac_platform helper
Date: Fri, 6 Jul 2012 23:40:31 +0100
Message-ID: <1341614431.2923.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
	 <20120705024446.26317.49693.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <s-jan@ti.com>, <arnd@arndb.de>,
	<patches@linaro.org>, <tony@atomide.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <rostedt@goodmis.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Andy Green <andy.green@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120705024446.26317.49693.stgit@build.warmcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-07-05 at 10:44 +0800, Andy Green wrote:
[...]
> To make use of this safely you also need to make sure that any drivers that
> may compete for the bus ordinal you are using (eg, mUSB and ehci in Panda
> case) are loaded in a deterministic order.
[...]

This seems very restrictive... would it be practical to also allow a
driver name as a path component?

[...]
> --- /dev/null
> +++ b/include/net/mac-platform.h
> @@ -0,0 +1,39 @@
> +/*
> + * mac-platform.h:  Enforces platform-defined MAC for Async probed devices
> + */
> +
> +#ifndef __NET_MAC_PLATFORM_H__
> +#define __NET_MAC_PLATFORM_H__
> +
> +#include <linux/if_ether.h>
> +
> +/**
> + * struct mac_platform - associates asynchronously probed device path with
> + *			 MAC address to be assigned to the device when it
> + *			 is created

A kernel-doc summary is strictly limited to one line.  The longer
explanation can go in a paragraph under the field descriptions.

> + * @device_path: device path name of network device
> + * @mac: MAC address to assign to network device matching device path
> + * @list: can be left uninitialized when passing from platform
> + */
> +
> +struct mac_platform {
> +	char *device_path;
> +	u8 mac[ETH_ALEN];
> +	struct list_head list; /* unused in platform data usage */
> +};
[...]
> --- /dev/null
> +++ b/net/ethernet/mac-platform.c
[...]
> +static struct mac_platform *__mac_platform_check(struct device *dev)
> +{
> +	const char *path;
> +	const char *p;
> +	const char *try;
> +	int len;
> +	struct device *devn;
> +	struct mac_platform *tmp;
> +	struct list_head *pos;
> +
> +	list_for_each(pos, &mac_platform_list) {
> +
> +		tmp = list_entry(pos, struct mac_platform, list);
> +
> +		try = tmp->device_path;
> +
> +		p = try + strlen(try);
> +		devn = dev;
> +
> +		while (devn) {
> +
> +			path = dev_name(devn);
> +			len = strlen(path);
> +
> +			if ((p - try) < len) {
> +				devn = NULL;
> +				continue;
> +			}
> +
> +			p -= len;
[...]

There are so many blank lines here, it's hard to see much code at once.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
