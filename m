From: Zahari Doychev <zahari.doychev@linux.com>
Subject: [PATCH][next] rocker: fix kcalloc parameter order
Date: Sun,  3 Sep 2017 22:26:03 +0200
Message-ID: <4d8a3c58c2a4e89319034f5faf41ba4682dc15ae.1504461594.git.zahari.doychev@linux.com>
Cc: Zahari Doychev <zahari.doychev@linux.com>
To: jiri@resnulli.us, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36904 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751569AbdICU0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 16:26:12 -0400
Received: by mail-wm0-f66.google.com with SMTP id x189so4761493wmg.4
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 13:26:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function calls to kcalloc use wrong parameter order. The flags
have to be passed as last parameter.

The change was done using the following coccinelle script:

@@
expression E1,E2;
type T;
@@

-kcalloc(E1, E2, sizeof(T))
+kcalloc(E2, sizeof(T), E1)

Signed-off-by: Zahari Doychev <zahari.doychev@linux.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index da4e26b53a52..2708451ce22a 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1177,7 +1177,7 @@ static int ofdpa_group_l2_fan_out(struct ofdpa_port *ofdpa_port,
 	entry->group_id = group_id;
 	entry->group_count = group_count;
 
-	entry->group_ids = kcalloc(flags, group_count, sizeof(u32));
+	entry->group_ids = kcalloc(group_count, sizeof(u32), flags);
 	if (!entry->group_ids) {
 		kfree(entry);
 		return -ENOMEM;
@@ -1456,7 +1456,7 @@ static int ofdpa_port_vlan_flood_group(struct ofdpa_port *ofdpa_port,
 	int err = 0;
 	int i;
 
-	group_ids = kcalloc(flags, port_count, sizeof(u32));
+	group_ids = kcalloc(port_count, sizeof(u32), flags);
 	if (!group_ids)
 		return -ENOMEM;
 
-- 
2.13.0
