From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/input/endev.c
Date: Wed, 19 Mar 2014 03:28:39 +0530
Message-ID: <1395179920-18392-1-git-send-email-monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/input/endev.c

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/input/evdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/input/evdev.c b/drivers/input/evdev.c
index 4cf2534..92e7a3c 100644
--- a/drivers/input/evdev.c
+++ b/drivers/input/evdev.c
@@ -174,7 +174,7 @@ static int evdev_ungrab(struct evdev *evdev, struct evdev_client *client)
 	if (evdev->grab != client)
 		return  -EINVAL;
 
-	rcu_assign_pointer(evdev->grab, NULL);
+	RCU_INIT_POINTER(evdev->grab, NULL);
 	synchronize_rcu();
 	input_release_device(&evdev->handle);
 
-- 
1.7.9.5
