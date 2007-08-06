From: Domen Puncer <domen.puncer@telargo.com>
Subject: phy_mii_ioctl - phydev->advertising ethtool.h vs. mii.h
Date: Mon, 6 Aug 2007 10:45:26 +0200
Message-ID: <20070806084526.GO4529@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: macro@linux-mips.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out001.atlarge.net ([129.41.63.69]:15200 "EHLO
	out001.atlarge.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbXHFIp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 04:45:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I've noticed mii-tool doesn't work right for a driver I'm just
developing (it uses generic phy layer).
Driver's ioctl is wired directly to phy_mii_ioctl().

"mii-tool -A something" shows the problem is in
phy_mii_ioctl -> SIOCSMIIREG:
392                         case MII_ADVERTISE:
393                                 phydev->advertising = val;
394                                 break;  

phydev->advertising value should be combined with ones from
ethtool.h (at least in other usages it is):
	437 #define ADVERTISED_10baseT_Half         (1 << 0)
	438 #define ADVERTISED_10baseT_Full         (1 << 1)
	439 #define ADVERTISED_100baseT_Half        (1 << 2)
	440 #define ADVERTISED_100baseT_Full        (1 << 3)

but mii-tool sends a mask with values from mii.h:
	 70 #define ADVERTISE_10HALF        0x0020  /* Try for 10mbps half-duplex  */
	 71 #define ADVERTISE_1000XFULL     0x0020  /* Try for 1000BASE-X full-duplex */
	 72 #define ADVERTISE_10FULL        0x0040  /* Try for 10mbps full-duplex  */
	 73 #define ADVERTISE_1000XHALF     0x0040  /* Try for 1000BASE-X half-duplex */
	 74 #define ADVERTISE_100HALF       0x0080  /* Try for 100mbps half-duplex */
	...

I'm I right that this is a bug?
Comments, suggestions how to fix it?


	Domen
