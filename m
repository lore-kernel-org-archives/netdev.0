From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v3 net-next 0/3] net: bcmgenet: only use new api ethtool_{get|set}_link_ksettings
Date: Mon, 26 Sep 2016 22:31:54 +0200
Message-ID: <1474921917-4773-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, jaedon.shin@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33725 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161226AbcIZUcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 16:32:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some times ago, a serie of patches were committed :
- commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from struct net_device")
- commit 6b352ebccbcf ("net: ethernet: broadcom: bcmgenet: use new api ethtool_{get|set}_link_ksettings")
The first patch add a regression on this driver, so it should be reverted.
As the second patch depend on the former, it should be reverted too.

The first patch is buggy because there is a "trick" in this driver.
The structure phydev is kept in the private data when the interface
go down, and used when the interface go up to enable the phy before
the function phy_connect is called.

I don't have this hardware, neither the datasheet. So I won't
update the driver to avoid this trick.

But the real goal of the first serie was to move to the new api
ethtool_{get|set}_link_ksettings. So I provide a new version of
the patch without the "cleaning" of driver to use the phydev
store in the net_device structure.

Changelog:
v3:
- use priv instead of dev (so all the code use the same phydev)
v2:
- use Florian Fainelli patches for the revert instead of Jaedon Shin
- simply use net: bcmgenet: for the prefix of the patch

Florian Fainelli (1):
  Revert "net: ethernet: bcmgenet: use phydev from struct net_device"

Philippe Reynes (2):
  Revert "net: ethernet: bcmgenet: use new api
    ethtool_{get|set}_link_ksettings"
  net: bcmgenet: use new api ethtool_{get|set}_link_ksettings

 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   45 +++++++++++++----------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |    1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |   24 +++++++------
 3 files changed, 39 insertions(+), 31 deletions(-)

-- 
1.7.4.4
