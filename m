From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/input/input.c
Date: Wed, 19 Mar 2014 03:30:29 +0530
Message-ID: <1395180029-18471-1-git-send-email-monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:60791 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaCRWBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 18:01:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/input/input.c

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/input/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/input/input.c b/drivers/input/input.c
index da38d97..41b5c82 100644
--- a/drivers/input/input.c
+++ b/drivers/input/input.c
@@ -463,7 +463,7 @@ static void __input_release_device(struct input_handle *handle)
 	struct input_dev *dev = handle->dev;
 
 	if (dev->grab == handle) {
-		rcu_assign_pointer(dev->grab, NULL);
+		RCU_INIT_POINTER(dev->grab, NULL);
 		/* Make sure input_pass_event() notices that grab is gone */
 		synchronize_rcu();
 
-- 
1.7.9.5
