From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/5] Cut off dn_ptr from net_device
Date: Mon, 22 Oct 2007 16:37:53 +0400
Message-ID: <471C99A1.8090202@openvz.org>
References: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39217 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbXJVMhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:37:13 -0400
In-Reply-To: <471C9830.5070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And remove a BUG_TRAP from netdev_run_todo as well.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 472d9cc..e94c636 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -577,7 +577,9 @@ struct net_device
 	
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
 	void			*ip_ptr;	/* IPv4 specific data	*/  
+#if defined(CONFIG_DECNET) || defined(CONFIG_DECNET_MODULE)
 	void                    *dn_ptr;        /* DECnet specific data */
+#endif
 	void                    *ip6_ptr;       /* IPv6 specific data */
 #if defined(CONFIG_ECONET) || defined(CONFIG_ECONET_MODULE)
 	void			*ec_ptr;	/* Econet specific data	*/
diff --git a/net/core/dev.c b/net/core/dev.c
index 8726589..3ac35fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3781,7 +3781,9 @@ void netdev_run_todo(void)
 		BUG_ON(atomic_read(&dev->refcnt));
 		BUG_TRAP(!dev->ip_ptr);
 		BUG_TRAP(!dev->ip6_ptr);
+#if defined(CONFIG_DECNET) || defined(CONFIG_DECNET_MODULE)
 		BUG_TRAP(!dev->dn_ptr);
+#endif
 
 		if (dev->destructor)
 			dev->destructor(dev);
-- 
1.5.3.4

