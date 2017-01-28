From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 0/3] net-next: use one struct bgmac & add PHY support
Date: Sat, 28 Jan 2017 22:08:29 +0100
Message-ID: <20170128210832.26174-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35199 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752146AbdA1VJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 16:09:14 -0500
Received: by mail-lf0-f66.google.com with SMTP id v186so28565236lfa.2
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 13:09:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

This patchset adds support for initializing PHY using PHY subsystem.
It's required e.g. for wireless access point devices that use bgmac
supported Ethernet device connected to some external PHY.

Implementing this required accessing phydev in bcma specific code which
wasn't possible with core code allocating struct bgmac on its own. This
is why I needed to modify alloc_etherdev usage first.

Rafał Miłecki (3):
  net: bgmac: allocate struct bgmac just once & don't copy it
  net: bgmac: drop struct bcma_mdio we don't need anymore
  net: bgmac: use PHY subsystem for initializing PHY

 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 108 +++++++++++-------------
 drivers/net/ethernet/broadcom/bgmac-bcma.c      |   6 +-
 drivers/net/ethernet/broadcom/bgmac-platform.c  |   2 +-
 drivers/net/ethernet/broadcom/bgmac.c           |  24 ++++--
 drivers/net/ethernet/broadcom/bgmac.h           |   5 +-
 5 files changed, 72 insertions(+), 73 deletions(-)

-- 
2.11.0
