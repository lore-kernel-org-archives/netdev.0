From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Tue, 7 Jun 2011 10:49:12 +0300
Message-ID: <BANLkTi=8mHr=SaUacW5cFR5xqXPaxrg5Xw@mail.gmail.com>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
 <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com> <1307416765.2642.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56767 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1FGHtn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 03:49:43 -0400
Received: by iyb14 with SMTP id 14so3779091iyb.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 00:49:42 -0700 (PDT)
In-Reply-To: <1307416765.2642.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 7, 2011 at 6:19 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 07 juin 2011 =C3=A0 04:39 +0300, Lucian Adrian Grijincu a =C3=
=A9crit :
>> The most like case is that no one else is registering devices with a
>> name like "dummy%d".
>>
>> We can bring the complexity down by replacing:
>> - alloc_netdev_id which is O(N) with
>> - alloc_netdev_id which, on the average case, is O(1).
>>
>> $ time modprobe dummy numdummies=3D5000
>> - with alloc_netdev =C2=A0 : 9.50s
>> - with alloc_netdev_id: 3.50s
>>
>> NOTE: Stats generated on a heavily patched 3.0-rc1 which replaces th=
e
>> =C2=A0 =C2=A0 =C2=A0 current O(N^2) sysctl algorithm with a better o=
ne.
>
> Yes, and disabled hotplug I guess.


$ cat .config | grep HOTPLUG
CONFIG_HOTPLUG=3Dy
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_HOTPLUG_CPU=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
CONFIG_ACPI_HOTPLUG_CPU=3Dy
# CONFIG_HOTPLUG_PCI is not set

I would guess you're going for CONFIG_HOTPLUG_PCI or
CONFIG_HOTPLUG_CPU, but I don't understand the implications.


> Dont try this on a random computer ;)

Could you briefly explain what's at stake here? What can go wrong if
we do this? I wasn't advocating replacing all alloc_netdev calls with
the new call.


> # time modprobe dummy numdummies=3D5000
>
> real =C2=A0 =C2=A04m45.646s
> user =C2=A0 =C2=A00m0.000s
> sys =C2=A0 =C2=A0 0m12.440s
> # uptime
> =C2=A005:13:46 up 13:30, =C2=A03 users, =C2=A0load average: 11221.41,=
 6918.70, 3101.12
> # uptime
> =C2=A005:18:45 up 13:35, =C2=A03 users, =C2=A0load average: 12159.82,=
 10277.39, 5623.19


I don't get where you're going with these stats.

I don't care much about these patches, and even less if they're
fundamentally borked, but I'd like to know how/why they're not ok.

Please spare a second and illuminate me; I feel left out on a big joke.


--=20
=C2=A0.
=2E.: Lucian
