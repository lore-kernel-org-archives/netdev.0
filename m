From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 00/10] Fix warning and issues
Date: Fri, 29 Jul 2016 17:33:53 -0700
Message-ID: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34266 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcG3AdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 20:33:25 -0400
Received: by mail-pa0-f53.google.com with SMTP id fi15so35447900pac.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 17:33:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following warning and issues,

  1. Fix kbuild warning
	- drivers: net: xgene: Fix kbuild warning
  2. unmap DMA memory on xgene_Enet_delete_bufpoool() 
	- drivers: net: xgene: fix: Add dma_unmap_single
  3. Delete descriptor rings and buffer pools on error
	- drivers: net: xgene: fix: Delete descriptor rings and buffer pools
  4. Fix error desconstruction on probe()
 	- drivers: net: xgene: Fix error deconstruction path
  5. Fix RSS indirection table fields
 	- drivers: net: xgene: Fix RSS indirection table fields
  6. Change the port init sequence as per hardware specification
	- drivers: net: xgene: Change port init sequence
  7. Fix link not recovered after link is down issue
	- drivers: net: xgene: XFI PCS reset when link is down
  8. Fix link up is reported when no SFP+ module is plugged in issue
	- drivers: net: xgene: Poll link status via GPIO
	- dtb: xgene: Add rxlos-gpios property
	- Documentation: dtb: xgene: Add rxlos GPIO mapping

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---

Iyappan Subramanian (10):
  drivers: net: xgene: Fix kbuild warning
  drivers: net: xgene: fix: Add dma_unmap_single
  drivers: net: xgene: fix: Delete descriptor rings and buffer pools
  drivers: net: xgene: Fix error deconstruction path
  drivers: net: xgene: Fix RSS indirection table fields
  drivers: net: xgene: Change port init sequence
  drivers: net: xgene: XFI PCS reset when link is down
  drivers: net: xgene: Poll link status via GPIO
  dtb: xgene: Add rxlos-gpios property
  Documentation: dtb: xgene: Add rxlos GPIO mapping

 .../devicetree/bindings/net/apm-xgene-enet.txt     |  1 +
 arch/arm64/boot/dts/apm/apm-mustang.dts            |  1 +
 drivers/net/ethernet/apm/xgene/Kconfig             |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c    | 17 ++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h    | 10 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  7 +--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  6 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 69 +++++++++++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  | 53 ++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |  4 ++
 11 files changed, 140 insertions(+), 31 deletions(-)

-- 
1.9.1
