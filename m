From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Sat, 16 Jan 2010 17:16:11 +0100
Message-ID: <4B51E64B.6010706@openwrt.org>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com> <e2d7436a1001160800u11206f54iaf07bb92331a256a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ha, Tristram" <Tristram.Ha@micrel.com>,
	Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:53726 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124Ab0APQcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2010 11:32:18 -0500
In-Reply-To: <e2d7436a1001160800u11206f54iaf07bb92331a256a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-01-16 5:00 PM, Micha=B3 Miros=B3aw wrote:
> Hello,
>=20
> 2010/1/16 Ha, Tristram <Tristram.Ha@micrel.com>:
>> This is a new network driver for Micrel KSZ8841/KSZ8842 PCI Ethernet=
 chips.  The same driver can run both chips at the same time.  It suppo=
rts IPv4 TCP hardware checksumming and so can use scatter/gather transm=
ission.
>>
>> The KSZ8842 has a switch with lots of hardware configurations.  The =
driver uses the proc system to allow users to configure the switch.  If=
 this is not desired the whole thing can be removed by not calling the =
init_proc() function.
>>
>> The KSZ8842 switch has 2 ports.  Some users like to take direct cont=
rol of those ports.  So KSZ8842 has a multiple devices mode in which th=
e driver creates another network device so that users can specify which=
 port to send packets.  This mode is enabled by passing the "multi_dev=3D=
1" parameter to the driver during loading.
> [...]
>=20
> I briefly looked over the datasheet for your device and it looks like
> it has the same basic design idea as a "ROBO" switch from Broadcom
> that is used in bcm53xx SoCs. This can be seen as a 3-port switch wit=
h
> one port fixed to be link to CPU (a special kind of PHY).
>=20
> If my assumptions are correct, then I thing it would be better to hav=
e
> a driver that presents this device as two: one - an ethernet device,
> and second - a switch management interface like the one used in
> OpenWRT.
>=20
> Here are some links for reference:
> http://downloads.openwrt.org/kamikaze/8.09.2/kamikaze_8.09.2_source.t=
ar.bz2;
> subdir: package/switch/src/
>   -> switch management driver for ADMTEK Adm6996 and Broadcom BCM5325=
E/536x
Don't look at that ;)
The code you're referring to is just a simple hack of mine that is a
few years old now. It's going to be removed as soon as the drivers have
been ported to a proper API.

I've been working on a switch configuration API based on netlink, which=
=20
is being used on some of the other platforms in OpenWrt.

You can find the sources here:
https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/fil=
es/drivers/net/phy/swconfig.c
https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/fil=
es/include/linux/switch.h

It's meant to be used with drivers that hook into the PHY abstraction l=
ayer.
You can find an example of such a driver here:
https://dev.openwrt.org/export/19173/trunk/target/linux/generic-2.6/fil=
es/drivers/net/phy/rtl8306.c

I'll do the final cleanups and submit it for review once I have time to=
 do so.

- Felix
