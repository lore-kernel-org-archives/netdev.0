From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/5][UDP-Lite]: Clean up proc creation a bit.
Date: Mon, 24 Mar 2008 13:50:30 +0300
Message-ID: <47E78776.4010207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52740 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755340AbYCXKul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 06:50:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just introduce a helper to remove ifdefs from inside the
udplite4_register function. This will help to make the next
patch nicer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/udplite.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 8d42e34..653a6fc 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -82,6 +82,16 @@ static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udplite4_seq_fops,
 };
+
+static __init int udplite4_proc_init(void)
+{
+	return udp_proc_register(&init_net, &udplite4_seq_afinfo);
+}
+#else
+static inline int udplite4_proc_init(void)
+{
+	return 0;
+}
 #endif
 
 void __init udplite4_register(void)
@@ -94,10 +104,8 @@ void __init udplite4_register(void)
 
 	inet_register_protosw(&udplite4_protosw);
 
-#ifdef CONFIG_PROC_FS
-	if (udp_proc_register(&init_net, &udplite4_seq_afinfo))
+	if (udplite4_proc_init())
 		printk(KERN_ERR "%s: Cannot register /proc!\n", __func__);
-#endif
 	return;
 
 out_unregister_proto:
-- 
1.5.3.4

