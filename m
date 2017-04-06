From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] fm10k: disable receive queue when configuring ring
Date: Thu,  6 Apr 2017 00:54:55 -0700
Message-ID: <20170406075456.27757-7-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39569 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756675AbdDFHz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:59 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Write to RXQCTL register to disable the receive queue when configuring
the RX ring.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index c62d1884f75b..3e26d27ad213 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -754,6 +754,7 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	/* disable queue to avoid issues while updating state */
 	rxqctl = fm10k_read_reg(hw, FM10K_RXQCTL(reg_idx));
 	rxqctl &= ~FM10K_RXQCTL_ENABLE;
+	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), rxqctl);
 	fm10k_write_flush(hw);
 
 	/* possible poll here to verify ring resources have been cleaned */
-- 
2.12.2
