From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: dsa: bcm_sf2: CFP support
Date: Fri, 27 Jan 2017 13:05:11 -0800
Message-ID: <20170127210516.16704-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33198 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbdA0VOK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:14:10 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so25851501pgd.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:14:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom Compact Field Processor (CFP)
which is a classification and matching engine built into most Broadcom switches.

We support that using ethtool::rxnfc because it allows all known uses cases from
the users I support to work, and more importantly, it allows the selection of a
target rule index, which is later used by e.g: offloading hardware, this is an
essential feature that I could not find being supported with cls_* for instance.

Thanks

Florian Fainelli (4):
  net: dsa: Hook {get,set}_rxnfc ethtool operations
  net: dsa: bcm_sf2: Configure traffic classes to queue mapping
  net: dsa: bcm_sf2: Add CFP registers definitions
  net: dsa: bcm_sf2: Add support for ethtool::rxnfc

 drivers/net/dsa/Makefile       |   2 +-
 drivers/net/dsa/bcm_sf2.c      |  23 ++
 drivers/net/dsa/bcm_sf2.h      |  17 ++
 drivers/net/dsa/bcm_sf2_cfp.c  | 613 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2_regs.h | 150 ++++++++++
 include/net/dsa.h              |   8 +
 net/dsa/slave.c                |  26 ++
 7 files changed, 838 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/dsa/bcm_sf2_cfp.c

-- 
2.9.3
