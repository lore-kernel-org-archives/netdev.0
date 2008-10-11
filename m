From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000: allow VLAN devices to use TSO and CSUM offload
Date: Fri, 10 Oct 2008 18:34:58 -0700
Message-ID: <20081011013458.11804.35278.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:36693
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbYJKBfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 21:35:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

This patch changes e1000 to set vlan_features so TSO and CSUM
offload can be used by VLAN devices, similar as with the other
Intel drivers.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ad6da7b..dd5ea4e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1053,6 +1053,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= NETIF_F_LLTX;
 
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(hw);
 
 	/* initialize eeprom parameters */

