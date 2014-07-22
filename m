From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 0/2] net: phy: Prevent an MDIO bus from being unloaded while
 in use
Date: Tue, 22 Jul 2014 14:31:42 -0700
Message-ID: <CAGVrzcZHTkSZfSGaBoBKiTmWoeoczNK5VY90Zj3osmLaFkH=Fw@mail.gmail.com>
References: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAGVrzcYo7BKmjxLMfB7u8rkgE1o+CDkDkWvCSL4kZ8S3whx=hw@mail.gmail.com> <20140721185552.GA20027@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:63036 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbaGVVcX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:32:23 -0400
Received: by mail-oa0-f51.google.com with SMTP id o6so409216oag.38
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:32:22 -0700 (PDT)
In-Reply-To: <20140721185552.GA20027@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-21 11:55 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electr=
ons.com>:
> Hi Florian,
>
> Thanks for the quick reply.
>
> On 21 Jul 11:42 AM, Florian Fainelli wrote:
> [..]
>> >
>> > This patchset fixes this by calling module_{get,put} in the ethern=
et driver.
>> > After this patch, the mvmdio driver is no longer removable:
>> >
>> >   $ modprobe -r mvmdio
>> >   modprobe: can't unload module mvmdio: Resource temporarily unava=
ilable
>> >
>> > Of course, we can expect a few drivers to have the same need and t=
herefore
>> > we could argue about moving this to be part of the phydev connecti=
on.
>>
>> Right, that's exactly what jumps to mind when I take a look at your
>> patch set. As long as a PHY device connected to a particular MDIO bu=
s
>> is in used, we should make sure its refcount does not hit zero.
>>
>
> Any suggestions about where to do it? I think the right place is
> after the calls to bus_find_device() in of_phy_find_device() and
> phy_connect().

A common place that is guaranteed to be called by all
phy_{connect,attach}{,_direct} is phy_attach_direct(), presumably
right after the call to device_bind_driver for instance?

>
>> BTW, neither mvmdio nor mvneta seems to set their 'owner' field, is
>> that intentional?
>>
>
> Actually, I had a patch that did so and then dropped it. The owner
> is set to unconditionally for plaftorm drivers, so setting it has no
> effect. See include/linux/platform_device.h:

Ah, indeed, I guess a coccinelle spatch could clean up this redundant
assignment for a bunch of drivers then.

>
> /*
>  * use a macro to avoid include chaining to get THIS_MODULE
>  */
> #define platform_driver_register(drv) \
>         __platform_driver_register(drv, THIS_MODULE)
>
> --
> Ezequiel Garc=C3=ADa, Free Electrons
> Embedded Linux, Kernel and Android Engineering
> http://free-electrons.com



--=20
=46lorian
