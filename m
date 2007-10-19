From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/4] Cut off the queue_mapping field from sk_buff
Date: Fri, 19 Oct 2007 13:05:40 +0400
Message-ID: <47187364.9050102@openvz.org>
References: <471871E5.7060900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:48119 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764167AbXJSJFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 05:05:48 -0400
In-Reply-To: <471871E5.7060900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just hide it behind the #ifdef, because nobody wants
it now.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f93f22b..580ed1f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -301,8 +301,9 @@ struct sk_buff {
 #endif
 
 	int			iif;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	__u16			queue_mapping;
-
+#endif
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
