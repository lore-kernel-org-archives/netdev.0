From: sfeldma@gmail.com
Subject: [PATCH net-next 2/2] rocker: sparse: fix dynamic allocation on stack warning
Date: Fri,  6 Mar 2015 15:54:52 -0800
Message-ID: <1425686092-2836-2-git-send-email-sfeldma@gmail.com>
References: <1425686092-2836-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46153 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896AbbCFXx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 18:53:58 -0500
Received: by pabli10 with SMTP id li10so55370971pab.13
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 15:53:58 -0800 (PST)
In-Reply-To: <1425686092-2836-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 +-
 drivers/net/ethernet/rocker/rocker.h |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9629352..65e1403 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2955,7 +2955,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	struct rocker_port *p;
 	struct rocker *rocker = rocker_port->rocker;
 	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
-	u32 group_ids[rocker->port_count];
+	u32 group_ids[ROCKER_FP_PORTS_MAX];
 	u8 group_count = 0;
 	int err;
 	int i;
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 0a94b7c..51e430d 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -27,6 +27,8 @@ enum {
 	ROCKER_ENOBUFS = 105,
 };
 
+#define ROCKER_FP_PORTS_MAX 62
+
 #define PCI_VENDOR_ID_REDHAT		0x1b36
 #define PCI_DEVICE_ID_REDHAT_ROCKER	0x0006
 
-- 
1.7.10.4
