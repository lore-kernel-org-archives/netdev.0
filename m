From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Fwd: Mellanox ethernet card failed when probing
Date: Wed, 11 Apr 2012 10:12:21 +0200
Message-ID: <CAL8zT=iDe7UXfktgnMF332S6zcfZE54kjaMaF3W9W_ZTCWi9jw@mail.gmail.com>
References: <CAL8zT=gV=pe4Bnn188ngnPk8s=7JSGARY0g6uVHASVrUXNKeKg@mail.gmail.com>
 <4F2C1E88.1040304@hp.com> <CAL8zT=iXND+y+6Zfxb+rUHT0yaAdQZ6QG18BHAwbeY3z9FOuGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62669 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab2DKIMn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 04:12:43 -0400
Received: by wibhj6 with SMTP id hj6so4146343wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 01:12:42 -0700 (PDT)
In-Reply-To: <CAL8zT=iXND+y+6Zfxb+rUHT0yaAdQZ6QG18BHAwbeY3z9FOuGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/3 Rick Jones <rick.jones2@hp.com>
>
> On 02/03/2012 07:13 AM, Jean-Michel Hautbois wrote:
>>
>> Hi all,
>>
>> I am using a HP server with Mellanox ethernet cards in it.
>> I have compiled the latest linux 3.2 version, and I am encountering
>> the following error :
>>
>> [ 1094.644193] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2=
011)
>> [ 1094.644196] mlx4_core: Initializing 0000:06:00.0
>> [ 1097.183671] mlx4_core 0000:06:00.0: irq 84 for MSI/MSI-X
>> [ 1097.183681] mlx4_core 0000:06:00.0: irq 85 for MSI/MSI-X
>> [ 1097.183690] mlx4_core 0000:06:00.0: irq 86 for MSI/MSI-X
>> [ 1097.183697] mlx4_core 0000:06:00.0: irq 87 for MSI/MSI-X
>> [ 1097.201267] mlx4_core: Initializing 0000:06:00.1
>> [ 1097.201509] mlx4_core 0000:06:00.1: Multiple PFs not yet supporte=
d.
>> Skipping PF.
>> [ 1097.201844] mlx4_core: probe of 0000:06:00.1 failed with error -2=
2
>
> > ...
>
>> I think this is firmware related, but I don't know for sure.
>> I can't find any firmware generated in the /lib/firmware directory..=
=2E
>
>
> That error message seems to relate to SRIOV support:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We reset th=
e device and enable SRIOV only for physical
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * devices. =C2=
=A0Try to claim ownership on the device;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if already =
taken, skip -- do not allow multiple PFs */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D mlx4_g=
et_ownership(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (err < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_free_dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mlx4_warn(dev, "Multiple PFs =
not yet supported."
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0" Skipping PF.\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_free_dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>
> Isn't SRIOV support a "work in progress" for the Mellanox devices? =C2=
=A0The rest of the logging (snipped) seems to suggest that the ".0" PFs=
 did initialize correctly, so are you simply worried about the messages=
 in the log?
>
> rick jones


I am not worried only with this message, but when I am looking at my
devices, even if the mlx4_core module is loaded, I don't have my eth
device.
Initializing is ok, but probe fails, so I can't use the device, this
is what I am worried about :).
I have two types of devices : be2net and mlx4. I want to have bonding
between them, and using an old kernel (debian lenny, 2.6.26), and the
drivers directly recompiled from mellanox website I can get it work.
Using the latest kernel (3.4.0-rc2) and using "modprobe mlx4_en" I get
the same messages related to mlx4_core, but it loads some ethernet
ports.

When booting, it detects the mlx and udev loads mlx4_core, not mlx4_en.=
=2E.
I will try to force it (but I am sure there is a clean way to do that ;=
-)).

JM
