From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 17:28:33 +0100
Message-ID: <ac3eb2510903240928s6c42bc32pa0cd8a7f0e69b731@mail.gmail.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
	 <49C9087C.5070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:39311 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763281AbZCXQ2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 12:28:36 -0400
In-Reply-To: <49C9087C.5070907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 17:21, Patrick McHardy <kaber@trash.net> wrote:
> Matt Domsch wrote:
>>
>> 2) udev may have rules to change the device names. =C2=A0This is mos=
t often
>> =C2=A0 seen in the '70-persistent-net.rules' file. =C2=A0Here we hav=
e
>> =C2=A0 additional challenges:
>>
>> ...
>>
>> =C2=A0 c) udev may not always be able to change a device's name. =C2=
=A0If udev
>> =C2=A0 =C2=A0 =C2=A0uses the kernel assignment namespace (ethN), the=
n a rename of
>> =C2=A0 =C2=A0 =C2=A0eth0->eth1 may require renaming eth1->eth0 (or s=
omething else).
>> =C2=A0 =C2=A0 =C2=A0Udev operates on a single device instance at a t=
ime, it becomes
>> =C2=A0 =C2=A0 =C2=A0difficult to switch names around for multiple de=
vices, within
>> =C2=A0 =C2=A0 =C2=A0the single namespace.
>
> I would classify this as a bug, especially the fact that udev doesn't
> undo a failed rename, so you end up with ethX_rename. Virtual devices
> using the same MAC address trigger this reliably unless you add
> exceptions to the udev rules.

This is handled in most cases. Virtual interfaces claiming a
configured name and created before the "hardware" interface are not
handled, that's right, but pretty uncommon.

> You state that it only operates on one device at a time. If that is
> correct, I'm not sure why the _rename suffix is used at all instead
> of simply trying to assign the final name, which would avoid this
> problem.

How? The kernel assignes the names and the configured names may
conflict. So you possibly can not rename a device to the target name
when it's name is already taken. I don't see how to avoid this.

Thanks,
Kay
