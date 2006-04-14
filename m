From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/10] e1000: Dead variable cleanup
Date: Fri, 14 Apr 2006 11:37:00 -0700
Message-ID: <20060414183700.3461.43671.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53764 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751400AbWDNSdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:22 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Removal of unused rx_dropped counter.

Removed reference to E1000_CTRL_EXT_CANC which is no longer valid,
replaced with E1000_CTRL_EXT_INT_TIMER_CLR


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7ba1b16..6d7ba0b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1715,7 +1715,7 @@ e1000_configure_rx(struct e1000_adapter 
 	if (hw->mac_type >= e1000_82571) {
 		ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
 		/* Reset delay timers after every interrupt */
-		ctrl_ext |= E1000_CTRL_EXT_CANC;
+		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
 #ifdef CONFIG_E1000_NAPI
 		/* Auto-Mask interrupts upon ICR read. */
 		ctrl_ext |= E1000_CTRL_EXT_IAME;
@@ -3165,7 +3165,6 @@ e1000_update_stats(struct e1000_adapter 
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
 		adapter->stats.cexterr;
-	adapter->net_stats.rx_dropped = 0;
 	adapter->net_stats.rx_length_errors = adapter->stats.ruc +
 	                                      adapter->stats.roc;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
