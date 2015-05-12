From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: phy: broken turn-around support
Date: Tue, 12 May 2015 10:33:23 -0700
Message-ID: <1431452006-3219-1-git-send-email-f.fainelli@gmail.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com>
Cc: davem@davemloft.net, jogo@openwrt.org, bert@biot.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35962 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbbELRds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:33:48 -0400
Received: by pabsx10 with SMTP id sx10so20172880pab.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:33:48 -0700 (PDT)
In-Reply-To: <1431442563-10218-1-git-send-email-bert@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is an attempt at solving the broken turn-around problem in a way that
is not specific to the mdio-gpio driver, since it affects different kinds of
platforms.

We cannot make that localized to PHY device drivers because probing the PHY
device which has a broken turn-around can fail as early as in get_phy_id(),
therefore we need a bit of help from Device Tree/platform_data.

Florian Fainelli (3):
  net: phy: Add phy_ignore_ta_mask to account for broken turn-around
  of: mdio: Add a "broken-turn-around" property
  net: phy: mdio-gpio: Handle phy_ignore_ta_mask

 Documentation/devicetree/bindings/net/phy.txt | 3 +++
 drivers/net/phy/mdio-bitbang.c                | 7 +++++--
 drivers/of/of_mdio.c                          | 3 +++
 include/linux/phy.h                           | 3 +++
 4 files changed, 14 insertions(+), 2 deletions(-)

-- 
2.1.0
