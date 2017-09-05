From: Zahari Doychev <zahari.doychev@linux.com>
Subject: [PATCH][next v2] rocker: fix kcalloc parameter order
Date: Tue,  5 Sep 2017 21:49:58 +0200
Message-ID: <20170905194958.3436-1-zahari.doychev@linux.com>
Cc: Zahari Doychev <zahari.doychev@linux.com>
To: jiri@resnulli.us, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33011 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbdIETuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 15:50:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so3753532wmn.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 12:50:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function calls to kcalloc use wrong parameter order and incorrect flags
values. GFP_KERNEL is used instead of flags now and the order is corrected.

The change was done using the following coccinelle script:

@@
expression E1,E2;
type T;
@@

-kcalloc(E1, E2, sizeof(T))
+kcalloc(E2, sizeof(T), GFP_KERNEL)

Signed-off-by: Zahari Doychev <zahari.doychev@linux.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index da4e26b53a52..0653b70723a3 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1177,7 +1177,7 @@ static int ofdpa_group_l2_fan_out(struct ofdpa_port *ofdpa_port,
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = kcalloc(flags, group_count, sizeof(u32));
+	entry->group_ids = kcalloc(group_count, sizeof(u32), GFP_KERNEL);
 	if (!entry->group_ids) {
 		kfree(entry);
 		return -ENOMEM;
@@ -1456,7 +1456,7 @@ static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
 	int err = 0;
 	int i;
 
-	group_ids = kcalloc(flags, port_count, sizeof(u32));
+	group_ids = kcalloc(port_count, sizeof(u32), GFP_KERNEL);
 	if (!group_ids)
 		return -ENOMEM;
 
-- 
2.13.0
