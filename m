From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 4/6] xt_log: Make printk() in sb_close() optional
Date: Tue,  6 Mar 2012 00:19:46 +0100
Message-ID: <1330989588-26833-5-git-send-email-richard@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org,
	Richard Weinberger <richard@nod.at>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330989588-26833-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make printk() in sb_close() optional such that other modules
can build a log string without printing it using printk().

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/net/netfilter/xt_log.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
index 0dfb34a..767e08d 100644
--- a/include/net/netfilter/xt_log.h
+++ b/include/net/netfilter/xt_log.h
@@ -39,10 +39,12 @@ static struct sbuff *sb_open(void)
 	return m;
 }
 
-static void sb_close(struct sbuff *m)
+static void __sb_close(struct sbuff *m, int print)
 {
-	m->buf[m->count] = 0;
-	printk("%s\n", m->buf);
+	if (print) {
+		m->buf[m->count] = 0;
+		printk("%s\n", m->buf);
+	}
 
 	if (likely(m != &emergency))
 		kfree(m);
@@ -52,3 +54,4 @@ static void sb_close(struct sbuff *m)
 	}
 }
 
+#define sb_close(m)	__sb_close(m, 1)
-- 
1.7.7.3
