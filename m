From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/4] net: dsa: bcm_sf2: CFP support
Date: Mon, 30 Jan 2017 09:48:39 -0800
Message-ID: <20170130174843.29497-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36603 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdA3SWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 13:22:50 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so23758455pfo.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 10:22:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom Compact Field Processor (CFP)
which is a classification and matching engine built into most Broadcom switches.

We support that using ethtool::rxnfc because it allows all known uses cases from
the users I support to work, and more importantly, it allows the selection of a
target rule index, which is later used by e.g: offloading hardware, this is an
essential feature that I could not find being supported with cls_* for instance.

Thanks!

Changes in v3:

- rebased against latest net-next/master after Vivien's changes

Changes in v2:

- fixed modular builds reported by kbuild test robot

Florian Fainelli (4):
  net: dsa: Hook {get,set}_rxnfc ethtool operations
  net: dsa: bcm_sf2: Configure traffic classes to queue mapping
  net: dsa: bcm_sf2: Add CFP registers definitions
  net: dsa: bcm_sf2: Add support for ethtool::rxnfc

 drivers/net/dsa/Makefile       |   1 +
 drivers/net/dsa/bcm_sf2.c      |  23 ++
 drivers/net/dsa/bcm_sf2.h      |  17 ++
 drivers/net/dsa/bcm_sf2_cfp.c  | 613 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2_regs.h | 150 ++++++++++
 include/net/dsa.h              |   8 +
 net/dsa/slave.c                |  26 ++
 7 files changed, 838 insertions(+)
 create mode 100644 drivers/net/dsa/bcm_sf2_cfp.c

-- 
2.9.3
