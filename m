From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/4] ixgbe: Fix SFP log messages
Date: Tue, 30 Jun 2009 14:43:55 -0700
Message-ID: <20090630214349.17464.25370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:42614
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752551AbZF3VoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 17:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We had a wide range of log messages for the same sort of SFP
failure.  This patch makes them all more similar and less
confusing along with converting them to dev_err.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e756e22..30d8c0e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2701,7 +2701,10 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	 */
 	err = hw->phy.ops.identify(hw);
 	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		DPRINTK(PROBE, ERR, "PHY not supported on this NIC %d\n", err);
+		dev_err(&adapter->pdev->dev, "failed to initialize because "
+			"an unsupported SFP+ module type was detected.\n"
+			"Reload the driver after installing a supported "
+			"module.\n");
 		ixgbe_down(adapter);
 		return err;
 	}
@@ -3720,10 +3723,11 @@ static void ixgbe_sfp_task(struct work_struct *work)
 			goto reschedule;
 		ret = hw->phy.ops.reset(hw);
 		if (ret == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-			DPRINTK(PROBE, ERR, "failed to initialize because an "
-			        "unsupported SFP+ module type was detected.\n"
-			        "Reload the driver after installing a "
-			        "supported module.\n");
+			dev_err(&adapter->pdev->dev, "failed to initialize "
+				"because an unsupported SFP+ module type "
+				"was detected.\n"
+				"Reload the driver after installing a "
+				"supported module.\n");
 			unregister_netdev(adapter->netdev);
 		} else {
 			DPRINTK(PROBE, INFO, "detected SFP+: %d\n",
@@ -4526,7 +4530,10 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 	adapter->flags |= IXGBE_FLAG_IN_SFP_MOD_TASK;
 	err = hw->phy.ops.identify_sfp(hw);
 	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		DPRINTK(PROBE, ERR, "PHY not supported on this NIC %d\n", err);
+		dev_err(&adapter->pdev->dev, "failed to initialize because "
+			"an unsupported SFP+ module type was detected.\n"
+			"Reload the driver after installing a supported "
+			"module.\n");
 		ixgbe_down(adapter);
 		return;
 	}
@@ -5513,8 +5520,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			  round_jiffies(jiffies + (2 * HZ)));
 		err = 0;
 	} else if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		dev_err(&adapter->pdev->dev, "failed to load because an "
-		        "unsupported SFP+ module type was detected.\n");
+		dev_err(&adapter->pdev->dev, "failed to initialize because "
+			"an unsupported SFP+ module type was detected.\n"
+			"Reload the driver after installing a supported "
+			"module.\n");
 		goto err_sw_init;
 	} else if (err) {
 		dev_err(&adapter->pdev->dev, "HW Init failed: %d\n", err);

