From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: [PATCH] drivers: net: ethernet: 3com: fix return value
Date: Sat, 24 Dec 2016 00:00:15 +0100
Message-ID: <1482534015-7828-1-git-send-email-thomas.preisner+linux@fau.de>
Cc: linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de,
        thomas.preisner+linux@fau.de, dave@thedillows.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a few cases the err-variable is not set to a negative error code if a
function call fails and thus 0 is returned instead.
It may be better to set err to the proper negative error code before
returning.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188841

Reported-by: Pan Bian <bianpan2016@163.com>
Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
---
 drivers/net/ethernet/3com/typhoon.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index a0cacbe..9a3ab58 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2404,6 +2404,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if(!is_valid_ether_addr(dev->dev_addr)) {
 		err_msg = "Could not obtain valid ethernet address, aborting";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2413,6 +2414,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
 		err_msg = "Could not get Sleep Image version";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2455,6 +2457,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if(register_netdev(dev) < 0) {
 		err_msg = "unable to register netdev";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
-- 
2.7.4
