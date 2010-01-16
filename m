From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Sat, 16 Jan 2010 17:00:30 +0100
Message-ID: <e2d7436a1001160800u11206f54iaf07bb92331a256a@mail.gmail.com>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michael Buesch <mb@bu3sch.de>,
	Felix Fietkau <openwrt@nbd.name>
To: "Ha, Tristram" <Tristram.Ha@micrel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:57855 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab0APQAd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 11:00:33 -0500
In-Reply-To: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2010/1/16 Ha, Tristram <Tristram.Ha@micrel.com>:
> This is a new network driver for Micrel KSZ8841/KSZ8842 PCI Ethernet =
chips. =A0The same driver can run both chips at the same time. =A0It su=
pports IPv4 TCP hardware checksumming and so can use scatter/gather tra=
nsmission.
>
> The KSZ8842 has a switch with lots of hardware configurations. =A0The=
 driver uses the proc system to allow users to configure the switch. =A0=
If this is not desired the whole thing can be removed by not calling th=
e init_proc() function.
>
> The KSZ8842 switch has 2 ports. =A0Some users like to take direct con=
trol of those ports. =A0So KSZ8842 has a multiple devices mode in which=
 the driver creates another network device so that users can specify wh=
ich port to send packets. =A0This mode is enabled by passing the "multi=
_dev=3D1" parameter to the driver during loading.
[...]

I briefly looked over the datasheet for your device and it looks like
it has the same basic design idea as a "ROBO" switch from Broadcom
that is used in bcm53xx SoCs. This can be seen as a 3-port switch with
one port fixed to be link to CPU (a special kind of PHY).

If my assumptions are correct, then I thing it would be better to have
a driver that presents this device as two: one - an ethernet device,
and second - a switch management interface like the one used in
OpenWRT.

Here are some links for reference:
http://downloads.openwrt.org/kamikaze/8.09.2/kamikaze_8.09.2_source.tar=
=2Ebz2;
subdir: package/switch/src/
  -> switch management driver for ADMTEK Adm6996 and Broadcom BCM5325E/=
536x

(I'm adding switch driver's authors to CC list. I hope I picket the
correct address for Felix from 3 in the sources. :-)

Best Regards,
Micha=B3 Miros=B3aw
