From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 2/3] net: Add Keystone NetCP ethernet driver
Date: Mon, 15 Sep 2014 12:37:55 -0400 (EDT)
Message-ID: <20140915.123755.1868053059646672094.davem@davemloft.net>
References: <1410638839-14792-1-git-send-email-santosh.shilimkar@ti.com>
	<1410638839-14792-3-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sandeep_n-l0cyMroinI0@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
To: santosh.shilimkar-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410638839-14792-3-git-send-email-santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Date: Sat, 13 Sep 2014 16:07:18 -0400

> +	/* Find this module in the sub-tree for this device */
> +	devices = of_get_child_by_name(node, "netcp-devices");
> +	if (!devices) {
> +		dev_err(dev, "could not find netcp-devices node\n");
> +		return NETCP_MOD_PROBE_SKIPPED;
> +	}
> +
> +	for_each_available_child_of_node(devices, child) {
> +		const char *name = netcp_node_name(child);
> +
> +		if (!strcasecmp(module->name, name))
> +			break;
> +	}
> +
> +	/* If module not used for this device, skip it */
> +	if (child == NULL) {
> +		dev_warn(dev, "module(%s) not used for device\n", module->name);
> +		return NETCP_MOD_PROBE_SKIPPED;
> +	}

of_get_child_by_name() takes a reference to an OF node, you must release
it in the error path.

> +	inst_modpriv = devm_kzalloc(dev, sizeof(*inst_modpriv), GFP_KERNEL);
> +	if (!inst_modpriv) {
> +		dev_err(dev, "Failed to allocate instance for %s\n",
> +			module->name);
> +		return -ENOMEM;
> +	}

Likewise, but here you have to release both "devices" and "child".

You're going to have to fix this OF node refcount problem for this
entire probe routine.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
