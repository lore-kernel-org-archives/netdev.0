From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH] ipv4: Introduce ipip_offload_init helper function.
Date: Wed,  2 Aug 2017 09:34:15 -0700
Message-ID: <1501691655-3493-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33685 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdHBQec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 12:34:32 -0400
Received: by mail-pg0-f65.google.com with SMTP id u185so6989075pgb.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 09:34:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's convenient to init ipip offload. We will check
the return value, and print KERN_CRIT info on failure.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/ipv4/af_inet.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ce44fb..c888120 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1763,6 +1763,11 @@ static int __init init_inet_pernet_ops(void)
 	},
 };
 
+static int __init ipip_offload_init(void)
+{
+	return inet_add_offload(&ipip_offload, IPPROTO_IPIP);
+}
+
 static int __init ipv4_offload_init(void)
 {
 	/*
@@ -1772,9 +1777,10 @@ static int __init ipv4_offload_init(void)
 		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
 	if (tcpv4_offload_init() < 0)
 		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
+	if (ipip_offload_init() < 0)
+		pr_crit("%s: Cannot add IPIP protocol offload\n", __func__);
 
 	dev_add_offload(&ip_packet_offload);
-	inet_add_offload(&ipip_offload, IPPROTO_IPIP);
 	return 0;
 }
 
-- 
1.8.3.1
