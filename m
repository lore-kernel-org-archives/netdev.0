From: sfeldma@gmail.com
Subject: [PATCH net-next 1/2] rocker: NULL port if port probe fails
Date: Mon,  3 Aug 2015 22:31:17 -0700
Message-ID: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34206 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbbHDF3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:29:03 -0400
Received: by pawu10 with SMTP id u10so29874365paw.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:29:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Set port to NULL if port probe fails so we don't try to remove partially
initialized port on port probe err cleanup path.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7b4c347..0ab3a3b 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5005,6 +5005,7 @@ err_untagged_vlan:
 	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
 			   ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
+	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
 err_register_netdev:
 	free_netdev(dev);
-- 
1.7.10.4
