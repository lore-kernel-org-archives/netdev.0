From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] rocker: fix error return code in rocker_world_check_init()
Date: Sat, 22 Oct 2016 14:31:06 +0000
Message-ID: <1477146666-29671-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34448 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934263AbcJVObT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:31:19 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so11499412pfz.1
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:31:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -EINVAL from the error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 2e81b70..0f3265b 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1471,7 +1471,7 @@ static int rocker_world_check_init(struct rocker_port *rocker_port)
 	if (rocker->wops) {
 		if (rocker->wops->mode != mode) {
 			dev_err(&rocker->pdev->dev, "hardware has ports in different worlds, which is not supported\n");
-			return err;
+			return -EINVAL;
 		}
 		return 0;
 	}
