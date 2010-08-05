From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Thu, 05 Aug 2010 04:47:21 +0100
Message-ID: <1280980041.13192.628.camel@localhost>
References: <201008051302.06045.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32768 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788Ab0HEDrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 23:47:37 -0400
In-Reply-To: <201008051302.06045.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-05 at 13:02 +0930, Rusty Russell wrote:
> I often use "ethtool -i" command to check what driver controls the
> ehternet device.  But because current virtio_net driver doesn't
> support "ethtool -i", it becomes the following:
> 
>         # ethtool -i eth3
>         Cannot get driver information: Operation not supported
> 
> This patch simply adds the "ethtool -i" support. The following is the
> result when using the virtio_net driver with my patch applied to.
> 
>         # ethtool -i eth3
>         driver: virtio_net
>         version: N/A
>         firmware-version: N/A
>         bus-info: virtio0
> 
> Personally, "-i" is one of the most frequently-used option, and most
> network drivers support "ethtool -i", so I think virtio_net also
> should do.
[...]

This information is already available generically through sysfs:
    basename $(readlink /sys/class/net/eth3/device)
    basename $(readlink /sys/class/net/eth3/device/driver)

Given that, we should either recommend that people use that method
instead, or we should add an equivalent default implementation of the
get_drvinfo operation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

