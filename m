From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/4] net: micrel: Staticize local functions
Date: Mon, 05 Aug 2013 18:03:00 +0900
Message-ID: <002301ce91ba$9605cc30$c2116490$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:37431 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857Ab3HEJDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 05:03:06 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR100K66VT17NK0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 05 Aug 2013 18:03:01 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These local functions are used only in this file.
Fix the following sparse warnings:

drivers/net/ethernet/micrel/ks8842.c:708:6: warning: symbol 'ks8842_handle_rx' was not declared. Should it be static?
drivers/net/ethernet/micrel/ks8842.c:718:6: warning: symbol 'ks8842_handle_tx' was not declared. Should it be static?
drivers/net/ethernet/micrel/ks8842.c:727:6: warning: symbol 'ks8842_handle_rx_overrun' was not declared. Should it be static?
drivers/net/ethernet/micrel/ks8842.c:735:6: warning: symbol 'ks8842_tasklet' was not declared. Should it be static?
drivers/net/ethernet/micrel/ks8851_mll.c:691:6: warning: symbol 'ks_enable_qmu' was not declared. Should it be static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ks8842.c     |   10 ++++++----
 drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index e393d99..94b3bd6 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -705,7 +705,8 @@ static void ks8842_rx_frame(struct net_device *netdev,
 	ks8842_enable_bits(adapter, 0, 1 << 12, REG_QRFCR);
 }
 
-void ks8842_handle_rx(struct net_device *netdev, struct ks8842_adapter *adapter)
+static void ks8842_handle_rx(struct net_device *netdev,
+	struct ks8842_adapter *adapter)
 {
 	u16 rx_data = ks8842_read16(adapter, 16, REG_RXMIR) & 0x1fff;
 	netdev_dbg(netdev, "%s Entry - rx_data: %d\n", __func__, rx_data);
@@ -715,7 +716,8 @@ void ks8842_handle_rx(struct net_device *netdev, struct ks8842_adapter *adapter)
 	}
 }
 
-void ks8842_handle_tx(struct net_device *netdev, struct ks8842_adapter *adapter)
+static void ks8842_handle_tx(struct net_device *netdev,
+	struct ks8842_adapter *adapter)
 {
 	u16 sr = ks8842_read16(adapter, 16, REG_TXSR);
 	netdev_dbg(netdev, "%s - entry, sr: %x\n", __func__, sr);
@@ -724,7 +726,7 @@ void ks8842_handle_tx(struct net_device *netdev, struct ks8842_adapter *adapter)
 		netif_wake_queue(netdev);
 }
 
-void ks8842_handle_rx_overrun(struct net_device *netdev,
+static void ks8842_handle_rx_overrun(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
 	netdev_dbg(netdev, "%s: entry\n", __func__);
@@ -732,7 +734,7 @@ void ks8842_handle_rx_overrun(struct net_device *netdev,
 	netdev->stats.rx_fifo_errors++;
 }
 
-void ks8842_tasklet(unsigned long arg)
+static void ks8842_tasklet(unsigned long arg)
 {
 	struct net_device *netdev = (struct net_device *)arg;
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index ac20098..9f3f5db 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -688,7 +688,7 @@ static void ks_soft_reset(struct ks_net *ks, unsigned op)
 }
 
 
-void ks_enable_qmu(struct ks_net *ks)
+static void ks_enable_qmu(struct ks_net *ks)
 {
 	u16 w;
 
-- 
1.7.10.4
