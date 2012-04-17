From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak
Date: Tue, 17 Apr 2012 09:41:32 +0800
Message-ID: <201204170941274843290@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "eric.dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:54288 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab2DQBkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 21:40:39 -0400
Received: by dake40 with SMTP id e40so7640344dak.11
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 18:40:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 582ed93b990e88110287ed0388bcb9057b1b8591 Mon Sep 17 00:00:00 2001
From: majianpeng <majianpeng@gmail.com>
Date: Tue, 17 Apr 2012 09:36:26 +0800
Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.


Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 net/ipv4/route.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 167ea10..1984c82 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3504,7 +3504,11 @@ int __init ip_rt_init(void)
  * this nonsense will go away.
  */
 void __init ip_static_sysctl_init(void)
-{
-	register_sysctl_paths(ipv4_path, ipv4_skeleton);
+{
+	struct ctl_table_header *ctl_header;
+
+	ctl_header = register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	if (ctl_header)
+		kmemleak_not_leak(ctl_header);
 }
 #endif
-- 
1.7.5.4

 				
--------------
majianpeng
2012-04-17
