From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 5/8] l2tp: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:17 -0400
Message-ID: <1473425000-9782-6-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        stephen hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/l2tp/l2tp_core.h | 2 +-
 net/l2tp/l2tp_eth.c  | 4 ++--
 net/l2tp/l2tp_ppp.c  | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 5871537af387..2599af6378e4 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -139,7 +139,7 @@ struct l2tp_session {
 	void (*session_close)(struct l2tp_session *session);
 	void (*ref)(struct l2tp_session *session);
 	void (*deref)(struct l2tp_session *session);
-#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
+#if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 	void (*show)(struct seq_file *m, void *priv);
 #endif
 	uint8_t			priv[0];	/* private data */
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 57fc5a46ce06..ef2cd30ca06e 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -195,7 +195,7 @@ static void l2tp_eth_delete(struct l2tp_session *session)
 	}
 }
 
-#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
+#if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 static void l2tp_eth_show(struct seq_file *m, void *arg)
 {
 	struct l2tp_session *session = arg;
@@ -268,7 +268,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	priv->tunnel_sock = tunnel->sock;
 	session->recv_skb = l2tp_eth_dev_recv;
 	session->session_close = l2tp_eth_delete;
-#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
+#if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 	session->show = l2tp_eth_show;
 #endif
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 34eff77982cf..41d47bfda15c 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -552,7 +552,7 @@ out:
 	return error;
 }
 
-#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
+#if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 static void pppol2tp_show(struct seq_file *m, void *arg)
 {
 	struct l2tp_session *session = arg;
@@ -723,7 +723,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	session->recv_skb	= pppol2tp_recv;
 	session->session_close	= pppol2tp_session_close;
-#if defined(CONFIG_L2TP_DEBUGFS) || defined(CONFIG_L2TP_DEBUGFS_MODULE)
+#if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 	session->show		= pppol2tp_show;
 #endif
 
-- 
2.7.4
