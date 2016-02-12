From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/9] amd-xgbe: AMD XGBE driver updates 2016-02-12
Date: Fri, 12 Feb 2016 08:32:15 -0600
Message-ID: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0064.outbound.protection.outlook.com ([207.46.100.64]:31044
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750863AbcBLOr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:47:57 -0500
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
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |  391 ++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   33 +-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   16 +
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    6 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |   53 ++--
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   11 -
 8 files changed, 342 insertions(+), 217 deletions(-)

-- 
Tom Lendacky
