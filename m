From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] allow access to sysfs_groups member
Date: Fri, 13 Nov 2009 14:27:38 -0800
Message-ID: <20091113142738.1aa81a03@s6510>
References: <20091113105157.GA322@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54737 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756682AbZKMW1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 17:27:43 -0500
In-Reply-To: <20091113105157.GA322@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 11:51:57 +0100
Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:

> +/* Add a sysfs group to the netdev groups */
> +int netdev_sysfs_add_group(struct net_device *net,
> +		struct attribute_group *grp)
> +{
> +	struct attribute_group **groups = net->sysfs_groups;
> +	struct attribute_group **end;
> +
> +	/* end pointer, with room for null terminator */
> +	end = &net->sysfs_groups[ARRAY_SIZE(net->sysfs_groups) - 1];
> +	for (; groups < end; ++groups) {
> +		if (!*groups) {
> +			*groups = grp;
> +			return 0;
> +		}
> +	}
> +	return -ENOSPC;
> +}
> +EXPORT_SYMBOL(netdev_sysfs_add_group);

EXPORT_SYMBOL_GPL() for all device/sysfs related stuff.

Also, need some way to BUG() if this is done after device has
been registered.  

Another way to add sub-directories which is what bridge, bonding,
and others do is to use another kobject. I think this is what you
want for the case of two CAN objects under one netdevice.
