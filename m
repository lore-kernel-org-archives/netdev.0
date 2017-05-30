From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v3 0/6] stmmac: pci: Refactor DMI probing
Date: Tue, 30 May 2017 09:33:19 +0200
Message-ID: <cover.1496129604.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from goliath.siemens.de ([192.35.17.28]:43370 "EHLO
        goliath.siemens.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750867AbdE3Hdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 03:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cleanups of the way we probe DMI platforms in the driver. Reduces
a bit of open-coding and makes the logic easier reusable for any
potential DMI platform != Quark.

Tested on IOT2000 and Galileo Gen2.

Changes in v3:
 - Rename STMAC vendor ID define and use PCI_VDEVICE
 - rearrange stmmac_pci_find_phy_addr according to review feedback

Jan

Jan Kiszka (6):
  stmmac: pci: Make stmmac_pci_info structure constant
  stmmac: pci: Use stmmac_pci_info for all devices
  stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
  stmmac: pci: Select quark_pci_dmi_data from quark_default_data
  stmmac: pci: Use dmi_system_id table for retrieving PHY addresses
  stmmac: pci: Remove setup handler indirection via stmmac_pci_info

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 187 ++++++++++++-----------
 1 file changed, 100 insertions(+), 87 deletions(-)

-- 
2.12.3
