From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 0/2] net: support bgmac with B50212E B1 PHY
Date: Thu, 12 Oct 2017 10:21:24 +0200
Message-ID: <20171012082126.30660-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        Jon Mason <jon.mason@broadcom.com>,
        Steve Lin <steven.lin1@broadcom.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:38532 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752853AbdJLIWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:22:14 -0400
Received: by mail-lf0-f65.google.com with SMTP id m7so1581499lfe.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 01:22:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

I got a report that a board with BCM47189 SoC and B50212E B1 PHY doesn't
work well some devices as there is massive ping loss. After analyzing
PHY state it has appeared that is runs in slave mode and doesn't auto
switch to master properly when needed.

This patchset fixes this by:
1) Adding new flag support to the PHY driver for setting master mode
2) Modifying bgmac to request master mode for reported hardware

Rafał Miłecki (2):
  net: phy: broadcom: support new device flag for setting master mode
  net: bgmac: enable master mode for BCM54210E and B50212E PHYs

 drivers/net/ethernet/broadcom/bgmac-bcma.c | 8 +++++++-
 drivers/net/phy/broadcom.c                 | 6 ++++++
 include/linux/brcmphy.h                    | 1 +
 3 files changed, 14 insertions(+), 1 deletion(-)

-- 
2.11.0
