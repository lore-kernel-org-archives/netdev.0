From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 0/5] dwc_eth_qos: stability fixes and support for CMA
Date: Mon, 29 Feb 2016 16:22:29 +0100
Message-ID: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:53847 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbcB2PXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 10:23:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series has bug fixes for the dwc_eth_qos ethernet driver.

Mainly two stability fixes for problems found by Rabin Vincent:
- Successive starts and stops of the interface would trigger a DMA reset timeout.
- A race condition in the TX DMA handling could trigger a netdev watchdog
 timeout.

The memory allocation was improved to support use of the CMA as DMA allocator
backend.

Lars Persson (2):
  dwc_eth_qos: release descriptors outside netif_tx_lock
  dwc_eth_qos: do phy_start before resetting hardware

Rabin Vincent (3):
  dwc_eth_qos: fix race condition in dwceqos_start_xmit
  dwc_eth_qos: use GFP_KERNEL in dma_alloc_coherent()
  dwc_eth_qos: use DWCEQOS_MSG_DEFAULT

 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 45 ++++++++++++++++++++---------
 1 file changed, 31 insertions(+), 14 deletions(-)

-- 
2.1.4
