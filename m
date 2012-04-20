From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3.4-rc 4/9] pch_gbe: export a method to set the receive match address
Date: Fri, 20 Apr 2012 22:09:23 +0200
Message-ID: <69ba3908f1e95a8ac7c049238b71b5865cdca8af.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42353 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab2DTUKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:10:10 -0400
Received: by wibhj6 with SMTP id hj6so1022509wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:10:09 -0700 (PDT)
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

The code in phc_gbe_main will need to call this method in order to set the
station address register according to the receive time stamping filter.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h |    1 +
 drivers/ptp/ptp_pch.c                           |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index dd14915..9f3dbc4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -660,6 +660,7 @@ extern u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
 extern u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
 extern u64 pch_rx_snap_read(struct pci_dev *pdev);
 extern u64 pch_tx_snap_read(struct pci_dev *pdev);
+extern int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
 #endif
 
 /* pch_gbe_param.c */
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 847a3c3..9e397fe 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -308,7 +308,7 @@ static void pch_reset(struct pch_dev *chip)
  *				    traffic on the  ethernet interface
  * @addr:	dress which contain the column separated address to be used.
  */
-static int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
+int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
 {
 	s32 i;
 	struct pch_dev *chip = pci_get_drvdata(pdev);
@@ -352,6 +352,7 @@ static int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(pch_set_station_address);
 
 /*
  * Interrupt service routine
-- 
1.7.2.5
