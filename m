From: Richard Weinberger <rw@linutronix.de>
Subject: [PATCH 2/5] xt_log: Make printk() in sb_close() optional
Date: Wed, 18 Jan 2012 23:43:27 +0100
Message-ID: <1326926610-17830-3-git-send-email-rw@linutronix.de>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>


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
1.7.7
