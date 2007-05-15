From: "H. Peter Anvin" <hpa@zytor.com>
Subject: [PATCH] [e1000] Lower the MSI unavailable message to INFO priority
Date: Tue, 15 May 2007 16:56:41 -0700
Message-ID: <200705152359.l4FNxPcS018779@tazenda.hos.anvin.org>
Cc: netdev@vger.kernel.org, hpa@zytor.com
To: e1000-devel@lists.sourceforge.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:44310 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703AbXEOX72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 19:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, if MSI is enabled but unavailable the e1000 prints an error
message "Unable to allocate MSI interrupt Error" with ERR priority.
This is confusing to users since this is not a functionality error;
the driver will immediately afterwards try to acquire a conventional
PIC/APIC interrupt and will print another message if that fails.

Accordingly, lower the priority of this message to INFO priority, since
it does not reflect any sort of loss of functionality, but rather just a
limitation of the configuration of the runtime system.

Signed-off-by: H. Peter Anvin <hpa@zytor.com>
---
 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 637ae8f..089ae3f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -307,7 +307,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	if (adapter->hw.mac_type >= e1000_82571) {
 		adapter->have_msi = TRUE;
 		if ((err = pci_enable_msi(adapter->pdev))) {
-			DPRINTK(PROBE, ERR,
+			DPRINTK(PROBE, INFO,
 			 "Unable to allocate MSI interrupt Error: %d\n", err);
 			adapter->have_msi = FALSE;
 		}
-- 
1.5.1.4

