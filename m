From: Pan Bian <bianpan201602@163.com>
Subject: [PATCH 1/1] net: ethernet: 3com: set error code on failures
Date: Sat,  3 Dec 2016 21:24:30 +0800
Message-ID: <1480771470-6404-1-git-send-email-bianpan201602@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: David Dillow <dave@thedillows.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

In function typhoon_init_one(), returns the value of variable err on
errors. However, on some error paths, variable err is not set to a
negative errno. This patch assigns "-EIO" to err on those paths.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/3com/typhoon.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 8f8418d..9a477fc 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2400,6 +2400,7 @@ enum state_values {
 
 	if(!is_valid_ether_addr(dev->dev_addr)) {
 		err_msg = "Could not obtain valid ethernet address, aborting";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2409,6 +2410,7 @@ enum state_values {
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
 	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
 		err_msg = "Could not get Sleep Image version";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2451,6 +2453,7 @@ enum state_values {
 
 	if(register_netdev(dev) < 0) {
 		err_msg = "unable to register netdev";
+		err = -EIO;
 		goto error_out_reset;
 	}
 
-- 
1.9.1
