From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Sat, 13 Jun 2009 09:51:38 +0200
Message-ID: <4A335A8A.5080907@gmail.com>
References: <ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>	<20090612.170128.213931980.davem@davemloft.net>	<4A334E7A.5020805@gmail.com> <20090613.000729.118500646.davem@davemloft.net>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:48136 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbZFMHvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 03:51:39 -0400
Received: by ewy6 with SMTP id 6so3601064ewy.37
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2009 00:51:41 -0700 (PDT)
In-Reply-To: <20090613.000729.118500646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I misunderstood the problem, thanks for asking me to clarify
> this.
>
> I thought the issue was the "in the environment where his devices
> would be used" he wanted to force a certain link speed and duplex
> setting.  In that case, forcing the link via ethtool is appropriate
> because it's an attribute of where the device is connected.
>   
Well I thought my initial post (in the smc91x force speed thread before
this patch was written) was quite unambiguous as to my motivation :

I am using the SMC91x driver on a based ARM board that has a hardware
problem causing 100Mbps mode not to work (even though the PHY
negotiates to that speed).


That being said even if this is _my_ use case the facility is equally
useful for the use case you understood (and yes you could use ethtool
from userspace/initramfs/initscript to do that but you've already
accepted the idea of an in kernel ethtool for the "environment" case).
> But the situation is different, the physical hardware has a limitation
> and know of this belongs, or should be described, in the driver
> somehow.
>   
Theoretically I agree. However the only practical advantage I can see of
doing it in the driver is that it is then impossible to later re-enable
broken modes. The proposed patch would allow you to later mess up
networking but requires :
1) ethtool installed on the device
2) root access to the device

If you have root access there are all manner of ways you can mess up the
system and breaking networking probably comes quite a way down the list.

If you want to do it in the driver for this usecase either it's back to
everyone for himself quick hacks or we need to add an interface to _all_
the drivers. How long would that take? How long did ethtool take? Given
the trouble this very non intrusive patch is having would you really
accept a patch to all the network drivers for this? I for one wouldn't
do it as I don't have all that hardware to test.

Even if we did go the "purist" route and add an interface to all the
drivers this patch would still be useful for the other usecase (the one
you understood).

So my argument is that while this patch is not the purist solution for
my usecase I consider it an acceptable solution (better than hacks) and
a good solution for other usecases.

Martin


