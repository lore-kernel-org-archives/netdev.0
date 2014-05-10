From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Sat, 10 May 2014 18:37:52 +0200
Message-ID: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:42466 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaEJQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 12:38:04 -0400
Received: by mail-ee0-f43.google.com with SMTP id d17so3474678eek.2
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 09:38:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

here's another aproach of solving the issue with auto-probed buses and
DT device nodes. In short, this patch set introduces a new hook which
sets the of_node pointer of a phy device to a subnode of the bus, if
there is any which matches the phy's address. This function is called
from mdiobus_scan(), and is a no-op for !CONFIG_OF.

Unlike with with the 1st version, dev->of_node is now available in the
PHY driver's probe() callback already.

Let me know what you think, I'm open to other ideas :)


Daniel


Daniel Mack (3):
  net: of_mdio: factor out code to parse a phy's 'reg' property
  net: of_mdio: add of_mdiobus_link_phydev()
  net: of_mdio: don't store the length of a property if we don't need to

 drivers/net/phy/mdio_bus.c |  6 ++++
 drivers/of/of_mdio.c       | 74 +++++++++++++++++++++++++++++++++++++---------
 include/linux/of_mdio.h    |  8 +++++
 3 files changed, 74 insertions(+), 14 deletions(-)

-- 
1.9.0
