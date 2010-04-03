From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] l2tp: Fix L2TP_DEBUGFS ifdef tests.
Date: Sat, 03 Apr 2010 15:04:40 -0700 (PDT)
Message-ID: <20100403.150440.57558969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752917Ab0DCWEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 18:04:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have to check CONFIG_L2TP_DEBUGFS_MODULE as well as
CONFIG_L2TP_DEBUGFS.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_core.h |    2 +-
 net/l2tp/l2tp_eth.c  |    4 ++--
 net/l2tp/l2tp_ppp.c  |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a961c77..91b1b9c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -133,7 +133,7 @@ struct l2tp_session {
 	void (*session_close)(struct l2tp_session *session);
 	void (*ref)(struct l2tp_session *session);
 	void (*deref)(struct l2tp_session *session);
-#ifdef CONFIG_L2TP_DEBUGFS
+#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
 	void (*show)(struct seq_file *m, void *priv);
 #endif
 	uint8_t			priv[0];	/* private data */
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 9848faa..ca1164a 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -172,7 +172,7 @@ static void l2tp_eth_delete(struct l2tp_session *session)
 	}
 }
 
-#ifdef CONFIG_L2TP_DEBUGFS
+#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
 static void l2tp_eth_show(struct seq_file *m, void *arg)
 {
 	struct l2tp_session *session = arg;
@@ -244,7 +244,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	priv->tunnel_sock = tunnel->sock;
 	session->recv_skb = l2tp_eth_dev_recv;
 	session->session_close = l2tp_eth_delete;
-#ifdef CONFIG_L2TP_DEBUGFS
+#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
 	session->show = l2tp_eth_show;
 #endif
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 1ef10e4..90d82b3 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -597,7 +597,7 @@ out:
 	return error;
 }
 
-#ifdef CONFIG_L2TP_DEBUGFS
+#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
 static void pppol2tp_show(struct seq_file *m, void *arg)
 {
 	struct l2tp_session *session = arg;
@@ -748,7 +748,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	session->recv_skb	= pppol2tp_recv;
 	session->session_close	= pppol2tp_session_close;
-#ifdef CONFIG_L2TP_DEBUGFS
+#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
 	session->show		= pppol2tp_show;
 #endif
 
-- 
1.7.0.4

