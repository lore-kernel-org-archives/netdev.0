From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/7] ixgbe: always enable vlan strip/insert when DCB
	is enabled
Date: Tue, 18 May 2010 19:00:08 -0700
Message-ID: <20100519020008.18654.36543.stgit@localhost.localdomain>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:39286 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576Ab0ESCAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:09 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

when DCB mode is on, we want the HW VLAN stripping to be always enabled.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a9e091c..f0f7329 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2845,7 +2845,11 @@ static void ixgbe_vlan_filter_disable(struct ixgbe_adapter *adapter)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		vlnctrl &= ~(IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE);
+		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
+#ifdef CONFIG_IXGBE_DCB
+		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+			vlnctrl &= ~IXGBE_VLNCTRL_VME;
+#endif
 		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		break;
@@ -2853,6 +2857,10 @@ static void ixgbe_vlan_filter_disable(struct ixgbe_adapter *adapter)
 		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+#ifdef CONFIG_IXGBE_DCB
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+			break;
+#endif
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));

