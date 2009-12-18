From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 4/6] net: Add netdev ops for SR-IOV configuration
Date: Fri, 18 Dec 2009 18:19:21 +0000
Message-ID: <1261160361.2769.20.camel@achroite.uk.solarflarecom.com>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
	 <20091218013444.4510.33545.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47398 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932382AbZLRSTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 13:19:25 -0500
In-Reply-To: <20091218013444.4510.33545.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-17 at 17:34 -0800, Jeff Kirsher wrote:
> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> Add netdev ops for configuring SR-IOV VF devices through the PF driver.

Though this be restricted to VFs, though?

It is possible to have virtualised interfaces appear as PFs, so they can
easily be passed-through to guests with no IOV support.  HP's 'Virtual
Connect Flex-10' NICs do this, but I'm not sure how they are configured
and whether it is possible to do so from Linux as opposed to firmware.

Solarstorm controllers also have an on-NIC page table and page-
segregated queues that can be mapped into PV guests, which could perhaps
be made configurable in the same way.

[...]
> @@ -660,6 +668,15 @@ struct net_device_ops {
>  #define HAVE_NETDEV_POLL
>  	void                    (*ndo_poll_controller)(struct net_device *dev);
>  #endif
> +	int			(*ndo_set_vf_mac)(struct net_device *dev,
> +						  int queue, u8 *mac);
> +	int			(*ndo_set_vf_vlan)(struct net_device *dev,
> +						   int queue, u16 vlan);
> +	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
> +						      int vf, int rate);
> +	int			(*ndo_get_vf_config)(struct net_device *dev,
> +						     int vf,
> +						     struct ifla_vf_info *ivf);
[...]

If these remain specific to IOV, presumably they should be guarded by
#ifdef CONFIG_PCI_IOV.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

