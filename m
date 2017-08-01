From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: set sriov_totalvfs correctly
Date: Tue, 1 Aug 2017 15:05:07 -0700
Message-ID: <20170801220507.GA1357@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0057.outbound.protection.outlook.com ([104.47.38.57]:30688
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752037AbdHAWF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 18:05:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

The file /sys/devices/pci000.../sriov_totalvfs is showing a wrong value.
Fix it by calling pci_sriov_set_totalvfs() to set the total number of VFs
available after calculations for the number of PF and VF queues are made.

Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1d8fefa..39a8dca 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1825,6 +1825,11 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 	case OCTEON_CN23XX_PCIID_PF:
 		oct->chip_id = OCTEON_CN23XX_PF_VID;
 		ret = setup_cn23xx_octeon_pf_device(oct);
+#ifdef CONFIG_PCI_IOV
+		if (!ret)
+			pci_sriov_set_totalvfs(oct->pci_dev,
+					       oct->sriov_info.max_vfs);
+#endif
 		s = "CN23XX";
 		break;
 
