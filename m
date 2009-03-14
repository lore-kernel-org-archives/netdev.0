From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/8] igb: switch to new dca API
Date: Fri, 13 Mar 2009 23:40:21 -0700
Message-ID: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:36493 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090AbZCNGkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:40:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Sosnowski <maciej.sosnowski@intel.com>

With the new DCA API, the driver should use dca3_get_tag() instead of
the obsolete dca_get_tag().

Signed-off-by: Maciej Sosnowski < maciej.sosnowski@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1adc7d2..230898f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3648,11 +3648,11 @@ static void igb_update_rx_dca(struct igb_ring *rx_ring)
 		dca_rxctrl = rd32(E1000_DCA_RXCTRL(q));
 		if (hw->mac.type == e1000_82576) {
 			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK_82576;
-			dca_rxctrl |= dca_get_tag(cpu) <<
+			dca_rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu) <<
 			              E1000_DCA_RXCTRL_CPUID_SHIFT;
 		} else {
 			dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK;
-			dca_rxctrl |= dca_get_tag(cpu);
+			dca_rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		}
 		dca_rxctrl |= E1000_DCA_RXCTRL_DESC_DCA_EN;
 		dca_rxctrl |= E1000_DCA_RXCTRL_HEAD_DCA_EN;
@@ -3675,11 +3675,11 @@ static void igb_update_tx_dca(struct igb_ring *tx_ring)
 		dca_txctrl = rd32(E1000_DCA_TXCTRL(q));
 		if (hw->mac.type == e1000_82576) {
 			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK_82576;
-			dca_txctrl |= dca_get_tag(cpu) <<
+			dca_txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu) <<
 			              E1000_DCA_TXCTRL_CPUID_SHIFT;
 		} else {
 			dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK;
-			dca_txctrl |= dca_get_tag(cpu);
+			dca_txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		}
 		dca_txctrl |= E1000_DCA_TXCTRL_DESC_DCA_EN;
 		wr32(E1000_DCA_TXCTRL(q), dca_txctrl);

