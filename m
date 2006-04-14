From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/10] e1000: Made an adapter struct variable into a local (txb2b)
Date: Fri, 14 Apr 2006 11:36:56 -0700
Message-ID: <20060414183656.3461.45688.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:50692 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751397AbWDNSdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:18 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Made an adapter struct variable into a local (txb2b)


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   10 +++++-----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 281de41..764808f 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -334,7 +334,6 @@ struct e1000_adapter {
 	boolean_t have_msi;
 #endif
 	/* to not mess up cache alignment, always add to the bottom */
-	boolean_t txb2b;
 #ifdef NETIF_F_TSO
 	boolean_t tso_force;
 #endif
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5e7b4ee..2cc9955 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2247,6 +2247,7 @@ e1000_watchdog_task(struct e1000_adapter
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
+			boolean_t txb2b = 1;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
@@ -2260,23 +2261,22 @@ e1000_watchdog_task(struct e1000_adapter
 			 * and adjust the timeout factor */
 			netdev->tx_queue_len = adapter->tx_queue_len;
 			adapter->tx_timeout_factor = 1;
-			adapter->txb2b = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				adapter->txb2b = 0;
+				txb2b = 0;
 				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 8;
 				break;
 			case SPEED_100:
-				adapter->txb2b = 0;
+				txb2b = 0;
 				netdev->tx_queue_len = 100;
 				/* maybe add some timeout factor ? */
 				break;
 			}
 
-			if ((adapter->hw.mac_type == e1000_82571 || 
+			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
-			    adapter->txb2b == 0) {
+			    txb2b == 0) {
 #define SPEED_MODE_BIT (1 << 21)
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
