From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-2.6 PATCH 1/10] Neterion: New driver: Driver help file
Date: Sun, 15 Mar 2009 19:04:39 +0000
Message-ID: <1237143879.4209.28.camel@hashbaz.i.decadent.org.uk>
References: <1237018830.4966.414.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50174 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752906AbZCOTHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 15:07:52 -0400
In-Reply-To: <1237018830.4966.414.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 00:20 -0800, Ramkrishna Vepa wrote:
[...]
> +1) Introduction:
> +----------------
> +Linux Driver for Neterion 10 Gigabit Ethernet PCI Express I/O Virtualized Server Adapter
> +
> + * This driver supports all Neterion's X3100 10GbE adapters and 2.4.x and 2.6.x kernels.

Any references to earlier kernel versions should be removed.

> + * Supports several features such as jumbo frames, MSI-X, checksum offloads, TSO, LRO and so on.
> +(See below for complete list of features supported for both IPv4 and IPv6)
> +
> +2) Load/Unload Neterion driver:
> +------------------------------

...works just the same as for any other driver.  Remove it.

> +3) Identifying the adapter/interface:
> +-------------------------------------

Same for most of this.

[...]
> +vii) napi
> +	Enables/disables NAPI support.
> +	Automatically disabled when intr_type is set to MSI-X on kernels below
> +	2.6.24.
> +	Valid range: 0,1 (disabled, enabled respectively)
> +	Default: 1

NAPI should be enabled all the time.  There is no need to make it an
option.

[...]
> +xi) rx_steering_type
> +	Specifies criteria for steering received packets.
> +	Valid range: 0-4 (disabled, L4 port, RTH, priority and VLAN ID respectively)
> +	Default: 2 (when system supports MSI-X and has more than 4 CPUs)

This should be controllable through ethtool ETHTOOL_{G,S}RXFH
operations.

[...]
> +xiv) ring_blocks:
> +	Numbers of RxD blocks in the ring
> +	Valid range: 1 - 128
> +	Default : 2

What's an RxD block?  Some fixed number of RX descriptors?  I think this
should be controllable through ethtool ETHTOOL_{G,S}RINGPARAM.

> +xv) Boot time configuration
> +	In order to load option(s) at boot time, add the option(s) to
> +	/etc/modprobe.conf.
> +	Example:
> +		alias eth# vxge
> +		options vxge rx_blocks=4 rx_steering_type=2

Just like any other module.

[...]
> +10) Ethtool Support:
> +--------------------
> +Ethtool is useful for driver configuration, diagnostics and displaying
> +statistical information.  The latest version of Ethtool is available at
> +http://sourceforge.net/projects/gkernel/
[...]

No need to duplicate ethtool docs here.

> +11) Known Issues:
> +-----------------
> +i) TSO disabled in SUSE 9:
> +	TSO is disabled by default in SuSE 9. It may be manually enabled
> +	using the ethtool command.
> +		# ethtool -K eth# tso on

Doesn't apply when using a current kernel (if that even works in SUSE
9).

> +12) Common Problems:
> +--------------------

These don't apply to in-tree modules.

[...]
> +13) Available Downloads:
> +------------------------

Not sure this belongs in-tree.

[...]
> +===============================================================================
> + Neterion Inc. Proprietary
> + COPYRIGHT (c) 2002-2009 Neterion Inc, ALL RIGHTS RESERVED

This notice _really_ doesn't belong in the kernel.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

