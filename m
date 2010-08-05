From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Wed, 04 Aug 2010 21:54:24 -0700 (PDT)
Message-ID: <20100804.215424.200345652.davem@davemloft.net>
References: <201008051302.06045.rusty@rustcorp.com.au>
	<1280980041.13192.628.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, mst@redhat.com,
	izumi.taku@jp.fujitsu.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59437
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751033Ab0HEEyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:54:07 -0400
In-Reply-To: <1280980041.13192.628.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 05 Aug 2010 04:47:21 +0100

> On Thu, 2010-08-05 at 13:02 +0930, Rusty Russell wrote:
>> I often use "ethtool -i" command to check what driver controls the
>> ehternet device.  But because current virtio_net driver doesn't
>> support "ethtool -i", it becomes the following:
>> 
>>         # ethtool -i eth3
>>         Cannot get driver information: Operation not supported
>> 
>> This patch simply adds the "ethtool -i" support. The following is the
>> result when using the virtio_net driver with my patch applied to.
>> 
>>         # ethtool -i eth3
>>         driver: virtio_net
>>         version: N/A
>>         firmware-version: N/A
>>         bus-info: virtio0
>> 
>> Personally, "-i" is one of the most frequently-used option, and most
>> network drivers support "ethtool -i", so I think virtio_net also
>> should do.
> [...]
> 
> This information is already available generically through sysfs:
>     basename $(readlink /sys/class/net/eth3/device)
>     basename $(readlink /sys/class/net/eth3/device/driver)
> 
> Given that, we should either recommend that people use that method
> instead, or we should add an equivalent default implementation of the
> get_drvinfo operation.

We've had ethtool for nearly a decade, it's a standard facility and
it's only wise to have all drivers implement as much of the API as
possible.

As such I've applied Rusty's patch and I will apply any patch which
makes a driver more fully provide support for all ethtool facilities.
