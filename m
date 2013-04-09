From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Tue, 09 Apr 2013 13:21:38 -0400 (EDT)
Message-ID: <20130409.132138.1712236757714558152.davem@davemloft.net>
References: <20130405094629.GV21448@secunet.com>
	<CAEnQRZDUjaL56AggThN50sYJpA8diQdQ85D4xCqpwtv8PbR7mg@mail.gmail.com>
	<20130409124735.GA21448@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaluta@ixiacom.com, nicolas.dichtel@6wind.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab3DIRVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 13:21:40 -0400
In-Reply-To: <20130409124735.GA21448@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 9 Apr 2013 14:47:35 +0200

> Hm, inet6_init() registers addrconf_notify() as a netdevice notifier
> function. So addrconf_notify() is called whenever a netdevice is
> registered. When looking at addrconf_notify(), there are only two
> cases when the net_device has no inet6_dev assigned. This is either
> on error, or if the device mtu is smaller than IPV6_MIN_MTU (i.e. 1280).
> 
> I can reproduce the behaviour you describe if I set the mtu of the
> ipv4 device to a value below IPV6_MIN_MTU, but in no other case.
> 
> Is it possible that your ipv4 device has a mtu below IPV6_MIN_MTU?

Like Steffen I am also curious how you are able to create a device
with no ipv6 device information attached, yet still have the ipv6
module loaded to the point where the ipv6 ipsec paths can execute.

If you're forcing this in an unnatural way or with localized changes,
I don't think we have anything to really fix.
