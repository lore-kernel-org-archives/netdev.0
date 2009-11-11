From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/4] venet-macvlan: add new driver to connect a venet
 to a	macvlan netdevice
Date: Wed, 11 Nov 2009 16:36:06 +0100
Message-ID: <4AFAD9E6.2020109@trash.net>
References: <20091110222632.24100.14884.stgit@mimic.site> <20091110222812.24100.42756.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, arnd@arndb.de,
	bridge@lists.linux-foundation.org, evb@yahoogroups.com,
	netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33572 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbZKKPgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 10:36:07 -0500
In-Reply-To: <20091110222812.24100.42756.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Mullaney wrote:
> This driver implements a macvlan device as a venet device that can
> be connected to vbus. Since it is a macvlan device, it provides
> a more direct path to the underlying adapter by avoiding the
> bridge.

> --- /dev/null
> +++ b/kernel/vbus/devices/venet/macvlan.c
> ...
> +struct venetmacv {
> +	struct macvlan_dev mdev;
> +	unsigned char ll_ifname[IFNAMSIZ];
> +	struct venetdev dev;
> +	const struct net_device_ops *macvlan_netdev_ops;
> +};

macvlan might destroy the device below you when the underlying
device is unregistered. You need to handle this by releasing
the venetmacv device. Check out the NETDEV_UNREGISTER case in
macvlan_device_event().
