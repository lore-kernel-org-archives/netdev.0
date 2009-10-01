From: Rainer Koenig <Rainer.Koenig@ts.fujitsu.com>
Subject: r8169c: Support for Realtek 8168DP chip?
Date: Thu, 01 Oct 2009 13:39:24 +0200
Message-ID: <4AC494EC.8050405@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dgate20.ts.fujitsu.com ([80.70.172.51]:34515 "EHLO
	dgate20.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490AbZJALtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 07:49:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I got several new workstation models  that come with the Realtek 8168DP
chip (8168 with DASH capabilites).
When trying to use this chip with the r8169 driver module I get the
following errors:

localhost kernel: r8169 0000:05:00.0: unknown MAC (2b800600)
localhost kernel: eth0: RTL8169 at 0xffffc2000004c000, 9:65:d3:9f, XID
28800000 IRQ 138
localhost kernel: eth0: PHY reset failed.
localhost kernel: r8169: eth0: TBI auto-negotiating
localhost kernel: r8169: eth0: unknown chipset (mac_version =3D 1).
localhost kernel: r8169: eth0: link down
localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready

The distribution running is RHEL 5.4, but actually that doesn't matter
since I didn't see the necessary code lines even in the latest blob fro=
m
git.kernel.org.

The reason why is easy to decode when looking at the source: The
TxConfig register returns 2b800000 and there is no MAC_VERSION in the
list of valid versions. That means not PHY initialization code is
executed and stop, no working device. :-(

The latest OEM download from Realtek
http://218.210.127.131/downloads/RedirectFTPSite.aspx?SiteID=3D1&DownTy=
peID=3D3&DownID=3D332&PFid=3D5&Conn=3D4
compiles and works. Looking at the source of this driver it shows code
for this TxConfig value and it has a special part for the PHY
initialization.

So the questions are:
- Will there be a patch for the 8168DP chip in the r8169 driver soon?
- What is necessary to get a patch?
- Are the maintainers of r8169 talking to the people that do the OEM
  driver or is r8169 just a reverse engineered driver?

Best regards
Rainer
--=20
Dipl.-Inf. (FH) Rainer Koenig
Project Manager Linux Business Clients
Dept. TSP CLI E SW OSE

=46ujitsu Technology Solutions
B=FCrgermeister-Ullrich-Str. 100
86199 Augsburg
Germany

Telephone: +49-821-804-3321
Telefax:   +49-821-804-2131
Mail:      mailto:Rainer.Koenig@ts.fujitsu.com

Internet         ts.fujtsu.com
Company Details  ts.fujitsu.com/imprint.html
