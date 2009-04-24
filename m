From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] vxge: fix possible NULL dereference in vxge-traffic.c
Date: Fri, 24 Apr 2009 05:31:38 +0400
Message-ID: <1240536698-10821-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: ram.vepa@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:40434 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbZDXBbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 21:31:43 -0400
Received: by fxm2 with SMTP id 2so862653fxm.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 18:31:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vpath is NULL then hldev is NULL also.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/vxge/vxge-traffic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 7be0ae1..506625b 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -1923,7 +1923,7 @@ enum vxge_hw_status __vxge_hw_vpath_alarm_process(
 	if (vpath == NULL) {
 		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
 			alarm_event);
-		goto out;
+		goto out2;
 	}
 
 	hldev = vpath->hldev;
@@ -2161,7 +2161,7 @@ enum vxge_hw_status __vxge_hw_vpath_alarm_process(
 	}
 out:
 	hldev->stats.sw_dev_err_stats.vpath_alarms++;
-
+out2:
 	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
 		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
 		return VXGE_HW_OK;
-- 
1.6.2.3

