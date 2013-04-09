From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Tue, 9 Apr 2013 20:31:30 +0300
Message-ID: <CAEnQRZB4ESaVwgiTScQyTp=Yo16aUhuonMJS7KzfNbs3zRoLFA@mail.gmail.com>
References: <20130405094629.GV21448@secunet.com>
	<CAEnQRZDUjaL56AggThN50sYJpA8diQdQ85D4xCqpwtv8PbR7mg@mail.gmail.com>
	<20130409124735.GA21448@secunet.com>
	<20130409.132138.1712236757714558152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steffen.klassert@secunet.com, nicolas.dichtel@6wind.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:62281 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765519Ab3DIRbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 13:31:31 -0400
Received: by mail-wg0-f41.google.com with SMTP id y10so5150286wgg.4
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 10:31:30 -0700 (PDT)
In-Reply-To: <20130409.132138.1712236757714558152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 9, 2013 at 8:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 9 Apr 2013 14:47:35 +0200
>
>> Hm, inet6_init() registers addrconf_notify() as a netdevice notifier
>> function. So addrconf_notify() is called whenever a netdevice is
>> registered. When looking at addrconf_notify(), there are only two
>> cases when the net_device has no inet6_dev assigned. This is either
>> on error, or if the device mtu is smaller than IPV6_MIN_MTU (i.e. 1280).
>>
>> I can reproduce the behaviour you describe if I set the mtu of the
>> ipv4 device to a value below IPV6_MIN_MTU, but in no other case.
>>
>> Is it possible that your ipv4 device has a mtu below IPV6_MIN_MTU?
>
> Like Steffen I am also curious how you are able to create a device
> with no ipv6 device information attached, yet still have the ipv6
> module loaded to the point where the ipv6 ipsec paths can execute.
>
> If you're forcing this in an unnatural way or with localized changes,
> I don't think we have anything to really fix.

Hi Dave, Steffen,

As I mentioned earlier in this thread we are using some custom kernel
modules that create the interfaces.

It's likely that these interfaces, for memory saving purposes, to skip attaching
ipv6 device information.

Anyhow, i still think that there is something wrong with commit 25ee3286dcbc
([IPSEC]: Merge common code into xfrm_bundle_create).

The code for xfrm is not easy to understand, so for this reason i
pointed out the problem to Nicolas in
the first place.

Thanks a lot.

Daniel.
