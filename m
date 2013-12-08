From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: drop_monitor: fix the value of maxattr
Date: Sun,  8 Dec 2013 09:36:56 -0500
Message-ID: <1386513416-97719-1-git-send-email-xiaosuo@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43063 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758773Ab3LHOiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 09:38:54 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so3673008pde.13
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 06:38:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

maxattr in genl_family should be used to save the max attribute
type, but not the max command type. Drop monitor doesn't support
any attributes, so we should leave it as zero.
---
 net/core/drop_monitor.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 9589718..e70301e 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -64,7 +64,6 @@ static struct genl_family net_drop_monitor_family = {
 	.hdrsize        = 0,
 	.name           = "NET_DM",
 	.version        = 2,
-	.maxattr        = NET_DM_CMD_MAX,
 };
 
 static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
-- 
1.7.9.5
