From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/4] bna: Staticize local functions
Date: Mon, 05 Aug 2013 18:00:04 +0900
Message-ID: <002001ce91ba$2d4b7eb0$87e27c10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Rasesh Mody' <rmody@brocade.com>,
	Jingoo Han <jg1.han@samsung.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11618 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836Ab3HEJAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 05:00:07 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR100BAEVMDKAL0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 05 Aug 2013 18:00:05 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bna_rx_sm_stop_wait_entry(), bna_rx_sm_rxf_stop_wait_entry(),
bna_rx_sm_started_entry(), bna_rx_sm_cleanup_wait_entry(),
and bna_rx_sm_cleanup_wait() are used only in this file.
Fix the following sparse warnings:

drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1423:1: warning: symbol 'bna_rx_sm_stop_wait_entry' was not declared. Should it be
static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1476:1: warning: symbol 'bna_rx_sm_rxf_stop_wait_entry' was not declared. Should it be
static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1532:1: warning: symbol 'bna_rx_sm_started_entry' was not declared. Should it be
static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1597:1: warning: symbol 'bna_rx_sm_cleanup_wait_entry' was not declared. Should it be
static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1602:1: warning: symbol 'bna_rx_sm_cleanup_wait' was not declared. Should it be static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 57cd1bf..3c07064 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -1419,7 +1419,7 @@ static void bna_rx_sm_start_wait_entry(struct bna_rx *rx)
 	bna_bfi_rx_enet_start(rx);
 }
 
-void
+static void
 bna_rx_sm_stop_wait_entry(struct bna_rx *rx)
 {
 }
@@ -1472,7 +1472,7 @@ static void bna_rx_sm_rxf_start_wait_entry(struct bna_rx *rx)
 	bna_rxf_start(&rx->rxf);
 }
 
-void
+static void
 bna_rx_sm_rxf_stop_wait_entry(struct bna_rx *rx)
 {
 }
@@ -1528,7 +1528,7 @@ bna_rx_sm_start_stop_wait(struct bna_rx *rx, enum bna_rx_event event)
 	}
 }
 
-void
+static void
 bna_rx_sm_started_entry(struct bna_rx *rx)
 {
 	struct bna_rxp *rxp;
@@ -1593,12 +1593,12 @@ static void bna_rx_sm_rxf_start_wait(struct bna_rx *rx,
 	}
 }
 
-void
+static void
 bna_rx_sm_cleanup_wait_entry(struct bna_rx *rx)
 {
 }
 
-void
+static void
 bna_rx_sm_cleanup_wait(struct bna_rx *rx, enum bna_rx_event event)
 {
 	switch (event) {
-- 
1.7.10.4
