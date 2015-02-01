From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] can: janz-ican3: fix type missmatch in assignment
Date: Sun,  1 Feb 2015 03:34:34 -0500
Message-ID: <1422779674-27823-1-git-send-email-hofrat@osadl.org>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <der.herr@hofr.at>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <der.herr@hofr.at>

return type of wait_for_completion_timeout is unsigned long not int, this
patch removes the type missmatch by moving the call into the condition.

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

The return type of wait_for_completion_timeout is unsigned long not
int. This patch resolves the type missmatch by moving the call to 
wait_for_completion_timeout into the condition. 

Patch was compile tested only for x86_64_defconfig + CONFIG_CAN=m
CONFIG_COMPILE_TEST=y, CONFIG_MFD_CS5535=m, CONFIG_OLPC=y
CONFIG_MFD_JANZ_CMODIO=m, CONFIG_CAN_JANZ_ICAN3=m

Patch is against 3.19.0-rc6 -next-20150130

 drivers/net/can/janz-ican3.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 0eb4d18..4dd183a 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1679,8 +1679,7 @@ static int ican3_get_berr_counter(const struct net_device *ndev,
 	if (ret)
 		return ret;
 
-	ret = wait_for_completion_timeout(&mod->buserror_comp, HZ);
-	if (ret == 0) {
+	if (!wait_for_completion_timeout(&mod->buserror_comp, HZ)) {
 		netdev_info(mod->ndev, "%s timed out\n", __func__);
 		return -ETIMEDOUT;
 	}
@@ -1705,8 +1704,7 @@ static ssize_t ican3_sysfs_show_term(struct device *dev,
 	if (ret)
 		return ret;
 
-	ret = wait_for_completion_timeout(&mod->termination_comp, HZ);
-	if (ret == 0) {
+	if (!wait_for_completion_timeout(&mod->termination_comp, HZ)) {
 		netdev_info(mod->ndev, "%s timed out\n", __func__);
 		return -ETIMEDOUT;
 	}
-- 
1.7.10.4

