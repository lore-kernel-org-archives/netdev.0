From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v3 0/2] OpenCores 10/100 MAC fixes for gigabit environment
Date: Tue,  4 Feb 2014 03:33:08 +0400
Message-ID: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:39082 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbaBCXdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:33:42 -0500
Received: by mail-lb0-f170.google.com with SMTP id u14so5973062lbd.1
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 15:33:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David, Ben, Florian, Chris and everybody,

this series improves ethoc behavior in gigabit environment:
- first patch disables gigabit advertisement in the attached PHY making
  possible to use gigabit link without any additional setup;
- second patch adds support to set up MII management bus frequency, adding
  new fields to platform data and to OF bindings.

These changes allow to use KC-705 board with 50MHz xtensa core and OpenCores
10/100 Mbps MAC connected to gigabit network without any additional setup.

Changes v2->v3:
- drop accessors for 'advertising' and 'supported' fields;
- don't call phy_start_aneg to force phylib to disable gigabit advertisement;
- drop clock-frequency property support;
- move ethtool operations to separate patchset.

Changes v1->v2:
- new patch "phy: provide accessors for 'advertising' and 'supported' fields";
- disable both gigabit advertisement and support;
- drop MDIO bus frequency configurability, always configure for standard
  2.5MHz;
- allow using common clock framework to provide ethoc clock;
- new patch: "net: ethoc: implement ethtool operations";
- drop device tree bindings documentation patch until common bindings format
  for network drivers is decided.


Max Filippov (2):
  net: ethoc: don't advertise gigabit speed on attached PHY
  net: ethoc: set up MII management bus clock

 drivers/net/ethernet/ethoc.c | 37 +++++++++++++++++++++++++++++++++++--
 include/net/ethoc.h          |  1 +
 2 files changed, 36 insertions(+), 2 deletions(-)

-- 
1.8.1.4
