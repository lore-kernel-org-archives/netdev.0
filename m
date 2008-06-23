From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] netdevice.h: don't export MAX_HEADER to userspace
Date: Mon, 23 Jun 2008 20:49:06 +0300
Message-ID: <20080623174906.GK4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:57986 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761569AbYFWRvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 13:51:03 -0400
Received: from cs181140183.pp.htv.fi (cs181140183.pp.htv.fi [82.181.140.183])
	by smtp4.pp.htv.fi (Postfix) with ESMTP id ACCFA5BC002
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:51:01 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the CONFIG_'s the value is anyway not correct in userspace.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/netdevice.h |    4 ++++
 1 file changed, 4 insertions(+)

2ac2f37cf11560e4ac858549a250ef473aed544d diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..25f8710 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -88,6 +88,8 @@ struct wireless_dev;
 #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
 #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
 
+#ifdef  __KERNEL__
+
 /*
  *	Compute the worst case header length according to the protocols
  *	used.
@@ -114,6 +116,8 @@ struct wireless_dev;
 #define MAX_HEADER (LL_MAX_HEADER + 48)
 #endif
 
+#endif  /*  __KERNEL__  */
+
 struct net_device_subqueue
 {
 	/* Give a control state for each queue.  This struct may contain

