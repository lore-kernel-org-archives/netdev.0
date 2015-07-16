From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169: set bits on Register Interrupt status on limit
Date: Thu, 16 Jul 2015 13:18:54 +0300
Message-ID: <1437041934-2587-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------mine-boundary-string"
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:33440 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726AbbGPKTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 06:19:14 -0400
Received: by wgmn9 with SMTP id n9so54536729wgm.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 03:19:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------mine-boundary-string
Content-Type: text/plain; charset=UTF-8; format=fixed
Content-Transfer-Encoding: 8bit


 Set bits on register Interrupt status on limits by
configuration(critical).
 On chips not alls bits is in use and some is reserved this patch solve this issue.

 Committer: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
 Changes to be committed:
	modified:   drivers/net/ethernet/realtek/r8169.c

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)


--------------mine-boundary-string
Content-Type: text/x-patch; name="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 744f90a..714af89 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8181,6 +8181,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	else
 		tp->rx_buf_sz = 16383;
 
+	tp->event_slow = cfg->event_slow;
+
+
 	rtl_init_rxcfg(tp);
 
 	rtl_irq_disable(tp);
@@ -8189,7 +8192,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_hw_reset(tp);
 
-	rtl_ack_events(tp, 0xffff);
+	rtl_ack_events(tp, 0xffff & tp->event_slow);
 
 	pci_set_master(pdev);
 
@@ -8325,7 +8328,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hw_features |= NETIF_F_RXFCS;
 
 	tp->hw_start = cfg->hw_start;
-	tp->event_slow = cfg->event_slow;
+	//tp->event_slow = cfg->event_slow;
 
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;

--------------mine-boundary-string--
