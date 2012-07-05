From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4 2/4] NET ethernet introduce mac_platform helper
Date: Wed, 04 Jul 2012 20:12:43 -0700
Message-ID: <1341457963.2058.13.camel@joe2Laptop>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
	 <20120705024446.26317.49693.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, s-jan@ti.com, arnd@arndb.de,
	patches@linaro.org, tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org,
	linux-arm-kernel@lists.infradead.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44356 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751403Ab2GEDMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2012 23:12:44 -0400
In-Reply-To: <20120705024446.26317.49693.stgit@build.warmcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 10:44 +0800, Andy Green wrote:
> From: Andy Green <andy@warmcat.com>
> 
> This introduces a small helper in net/ethernet, which registers a network
> notifier at core_initcall time, and accepts registrations mapping expected
> asynchronously-probed network device paths (like, "usb1/1-1/1-1.1/1-1.1:1.0")
> and the MAC that is needed to be assigned to the device when it appears.

The mac prefix is poor.  I think eth_mac is better.

[]

> diff --git a/net/ethernet/mac-platform.c b/net/ethernet/mac-platform.c
[]
> +static int mac_platform_netdev_event(struct notifier_block *this,
> +						unsigned long event, void *ptr)

alignment to parenthesis please.

[]

> +int mac_platform_register_device_macs(const struct mac_platform *macs)
> +{
[]
> +		next = kmalloc(sizeof(struct mac_platform), GFP_KERNEL);
> +		if (!next) {
> +			ret = -ENOMEM;
> +			goto bail;
> +		}
> +
> +		next->device_path = kmalloc(strlen(macs->device_path) + 1,
> +								   GFP_KERNEL);
> +		if (!next->device_path) {
> +			ret = -ENOMEM;
> +			goto bail;
> +		}
> +
> +		strcpy(next->device_path, macs->device_path);
> +		memcpy(next->mac, macs->mac, sizeof macs->mac);

kmemdup and kstrdup()

> +		list_add(&next->list, &mac_platform_list);
> +
> +		macs++;
> +	}
> +
> +bail:
> +	mutex_unlock(&mac_platform_mutex);
> +
> +	return ret;
> +}

leaking memory on failures.
