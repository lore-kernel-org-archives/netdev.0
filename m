From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/2] Netfilter: xt_LOG: Add timestamp support
Date: Wed, 15 Feb 2012 14:55:15 +0100
Message-ID: <1329314115-6899-2-git-send-email-richard@nod.at>
References: <1329314115-6899-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jengelh@medozas.de, rostedt@goodmis.org,
	pablo@netfilter.org, basti@b-bl.de,
	Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1329314115-6899-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using XT_LOG_ADD_TIMESTAMP it is possible to have a timestamp
directly in the log message.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netfilter/xt_LOG.h |    1 +
 net/netfilter/xt_LOG.c           |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
index e4b1177..d84710c 100644
--- a/include/linux/netfilter/xt_LOG.h
+++ b/include/linux/netfilter/xt_LOG.h
@@ -8,6 +8,7 @@
 #define XT_LOG_UID		0x08	/* Log UID owning local socket */
 #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
 #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
+#define XT_LOG_ADD_TIMESTAMP	0x40	/* Add a timestamp */
 #define XT_LOG_MASK		0x6f
 
 struct xt_log_info {
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 211d341..2af2621 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -490,6 +490,15 @@ log_packet_common(struct sbuff *m,
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		sb_add(m, "<%d>", loginfo->u.log.level);
 
+	if (loginfo->u.log.logflags & XT_LOG_ADD_TIMESTAMP) {
+		struct timespec tv;
+		unsigned int msec;
+
+		getnstimeofday(&tv);
+		msec = tv.tv_nsec / NSEC_PER_MSEC;
+		sb_add(m, "TIMESTAMP=%li.%03li ", tv.tv_sec, msec);
+	}
+
 	sb_add(m, "%sIN=%s OUT=%s ", prefix, in ? in->name : "",
 	       out ? out->name : "");
 #ifdef CONFIG_BRIDGE_NETFILTER
-- 
1.7.7.3

