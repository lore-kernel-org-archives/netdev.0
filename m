From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 6/6] Netfilter: xt_LOG: Add timestamp support
Date: Tue,  6 Mar 2012 00:19:48 +0100
Message-ID: <1330989588-26833-7-git-send-email-richard@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org,
	Richard Weinberger <richard@nod.at>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330989588-26833-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using XT_LOG_ADD_TIMESTAMP it is possible to have a timestamp
directly in the log message.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netfilter/xt_LOG.h |    3 ++-
 net/netfilter/xt_LOG.c           |    8 ++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
index 8ac25e0..9361374 100644
--- a/include/linux/netfilter/xt_LOG.h
+++ b/include/linux/netfilter/xt_LOG.h
@@ -8,7 +8,8 @@
 #define XT_LOG_UID		0x08	/* Log UID owning local socket */
 #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
 #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
-#define XT_LOG_MASK		0x2f
+#define XT_LOG_ADD_TIMESTAMP	0x40    /* Add a timestamp */
+#define XT_LOG_MASK		0x6f
 
 struct xt_log_info {
         unsigned char level;
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index f75f2d7..23db206 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -499,6 +499,14 @@ log_packet_common(struct sbuff *m,
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		sb_add(m, "<%d>", loginfo->u.log.level);
 
+	if (loginfo->u.log.logflags & XT_LOG_ADD_TIMESTAMP) {
+		struct timespec tv;
+
+		getnstimeofday(&tv);
+		sb_add(m, "TIMESTAMP=%li.%03u ", tv.tv_sec,
+			(unsigned int)tv.tv_nsec / NSEC_PER_MSEC);
+	}
+
 	sb_add(m, "%sIN=%s OUT=%s ", prefix, in ? in->name : "",
 	       out ? out->name : "");
 #ifdef CONFIG_BRIDGE_NETFILTER
-- 
1.7.7.3

