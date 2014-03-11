From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port switch
Date: Tue, 11 Mar 2014 16:49:49 +0100
Message-ID: <CAGm1_kt9eDRtqwL-twLKheW-XMD8RJ7Rmmsbxwdd6EB2NkopOQ@mail.gmail.com>
References: <1393492072-15364-1-git-send-email-sr@denx.de> <20140227.170240.1910151216729314077.davem@davemloft.net>
 <CAGVrzcZd7mO6t4eAsn6HVNWFZpPopkBk2trjgSh+3rcWQPHw7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Felix Fietkau <nbd@openwrt.org>, Stefan Roese <sr@denx.de>,
	netdev <netdev@vger.kernel.org>, r.meier@siemens.com,
	lukas.stockmann@siemens.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:53808 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbaCKPuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 11:50:13 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so9020579pbb.11
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 08:50:09 -0700 (PDT)
In-Reply-To: <CAGVrzcZd7mO6t4eAsn6HVNWFZpPopkBk2trjgSh+3rcWQPHw7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Thu, Feb 27, 2014 at 11:21 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-02-27 14:02 GMT-08:00 David Miller <davem@davemloft.net>:
>> From: Stefan Roese <sr@denx.de>
>> Date: Thu, 27 Feb 2014 10:07:52 +0100
>>
>>> This driver exposes a sysfs interface to access the LAN9303 registers to
>>> userspace. These sysfs files can be used to configure the switch.
>>>
>>> Signed-off-by: Stefan Roese <sr@denx.de>
>>
>> We have an abstraction for programming switch devices called DSA.
>>
>> Even if DSA doesn't fullfill your needs, doing adjustments using sysfs
>> files in userland is going to be the worst user experience possible.
>
> If you remember the discussion that started around the 'swconfig'
> patches, DSA is not suitable for all types of switches, especially not
> those which have no proprietary tagging support (which are about 80%
> of the switches used in embedded systems). That discussion has kind of
> stalled now, so we should probably bring it back...
>
>>
>> Every driver will export different things to tweak, each device will
>> have different semantics and limitations for these settings, etc.
>>
>> Better is to come up with a real, types, interface for programming
>> such devices and providing an implementation of that.
>
> These are definitively the goals of the 'swconfig' patches that were
> posted a while ago, to provide an unified programming API.
> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Have you tried to apply your swconfig patches to 3.14? There some
compiler errors meanwhile. genl_register_ops() is not available, so
one has to switch to genl_register_family_with_ops() or similar
macros. It would be great, if you could post the updates series and if
possible with ICplus drive included.

Yegor
