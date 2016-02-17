From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 0/9] amd-xgbe: AMD XGBE driver updates 2016-02-12
Date: Wed, 17 Feb 2016 11:47:58 -0600
Message-ID: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0086.outbound.protection.outlook.com ([157.56.111.86]:27780
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964878AbcBQRsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:48:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following updates and fixes are included in this driver update series:

- Disable VLAN filtering in promiscuous mode
- Change from using napi_complete to napi_complete_done
- Use __napi_schedule_irqoff when running in interrupt context
- Verify ethtool speed setting is valid for the selected speedset
- Enable PFC based on the pfc_en setting
- Fix the mapping of priorities to traffic classes
- Do traffic class setup when DCB nl callbacks are invoked
- Check Rx queue fifos before stopping Rx queue DMA
- Switch from disable_irq to masking interrupts for auto-negotiation

This patch series is based on net-next.

---

Changes from v1:
- Removed #ifndef and #define of CRCPOLY_LE as part of the patch to
  disable VLAN filtering in promiscuous mode
- Reworked changes to xgbe_setup_tc to resolve conflicts with commit
  16e5cc647173 (net: rework setup_tc ndo op to consume general tc operand)

Tom Lendacky (9):
      amd-xgbe: Disable VLAN filtering when in promiscuous mode
      amd-xgbe: Change from napi_complete to napi_complete_done
      amd-xgbe: Use __napi_schedule_irqoff
      amd-xgbe: Verify forced speed matches the active speedset
      amd-xgbe: Enable/disable PFC per traffic class
      amd-xgbe: Fix the mapping of priorities to traffic classes
      amd-xgbe: Do traffic class setup when called through dcbnl
      amd-xgbe: Check Rx queue fifos before stopping Rx DMA
      amd-xgbe: Mask auto-negotiation interrupts in ISR


 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |   10 -
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c     |   39 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |  388 ++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   34 +-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   16 +
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    6 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |   53 ++--
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   11 -
 8 files changed, 340 insertions(+), 217 deletions(-)

-- 
Tom Lendacky
