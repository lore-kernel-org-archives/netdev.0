From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v3 net-next 0/6] drivers: net: xgene-v2: Add RGMII based 1G driver
Date: Fri,  3 Mar 2017 17:09:26 -0800
Message-ID: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35907 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751733AbdCDBIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 20:08:41 -0500
Received: by mail-pf0-f181.google.com with SMTP id x66so38274781pfb.3
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 17:08:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for RGMII based 1GbE hardware which uses a linked
list of DMA descriptor architecture (v2) for APM X-Gene SoCs.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
v3: Address review comments from v2
	- fix kbuild warnings (this 'if' clause does not guard)

v2: Address review comments from v1
	- moved create_desc_ring and delete_desc_ring to open() and close()
	  respectively
	- changed to use dma_zalloc APIs
	- fixed tx_timeout()
	- removed tx completion polling upper bound
	- added error checking on rx packets
	- added netif_stop_queue() and netif_wake_queue()

v1:
	- Initial version
---

Iyappan Subramanian (6):
  drivers: net: xgene-v2: Add DMA descriptor
  drivers: net: xgene-v2: Add mac configuration
  drivers: net: xgene-v2: Add ethernet hardware configuration
  drivers: net: xgene-v2: Add base driver
  drivers: net: xgene-v2: Add transmit and receive
  MAINTAINERS: Add entry for APM X-Gene SoC Ethernet (v2) driver

 MAINTAINERS                                |   6 +
 drivers/net/ethernet/apm/Kconfig           |   1 +
 drivers/net/ethernet/apm/Makefile          |   1 +
 drivers/net/ethernet/apm/xgene-v2/Kconfig  |  11 +
 drivers/net/ethernet/apm/xgene-v2/Makefile |   6 +
 drivers/net/ethernet/apm/xgene-v2/enet.c   |  71 +++
 drivers/net/ethernet/apm/xgene-v2/enet.h   |  43 ++
 drivers/net/ethernet/apm/xgene-v2/mac.c    | 116 +++++
 drivers/net/ethernet/apm/xgene-v2/mac.h    | 110 +++++
 drivers/net/ethernet/apm/xgene-v2/main.c   | 756 +++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/main.h   |  75 +++
 drivers/net/ethernet/apm/xgene-v2/ring.c   |  81 ++++
 drivers/net/ethernet/apm/xgene-v2/ring.h   | 119 +++++
 13 files changed, 1396 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.h

-- 
1.9.1
