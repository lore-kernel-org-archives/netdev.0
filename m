From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: [PATCH] net: cleanup miss usage of seq_release_private
Date: Thu, 08 Jul 2004 04:26:14 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <871xjnmxex.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


These doesn't allocate memory and doesn't use seq->private. However
kfree() ignores NULL, so these are not the problem.

This patch just cleans these up.

Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
---

 net/ipv4/route.c              |    2 +-
 net/irda/discovery.c          |    2 +-
 net/irda/ircomm/ircomm_core.c |    2 +-
 net/irda/iriap.c              |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff -puN net/ipv4/route.c~net-seq_release-cleanup net/ipv4/route.c
--- linux-2.6.7/net/ipv4/route.c~net-seq_release-cleanup	2004-07-08 00:01:20.000000000 +0900
+++ linux-2.6.7-hirofumi/net/ipv4/route.c	2004-07-08 00:01:20.000000000 +0900
@@ -432,7 +432,7 @@ static struct file_operations rt_cpu_seq
 	.open	 = rt_cpu_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release,
 };
 
 #endif /* CONFIG_PROC_FS */
diff -puN net/irda/discovery.c~net-seq_release-cleanup net/irda/discovery.c
--- linux-2.6.7/net/irda/discovery.c~net-seq_release-cleanup	2004-07-08 00:01:20.000000000 +0900
+++ linux-2.6.7-hirofumi/net/irda/discovery.c	2004-07-08 00:01:20.000000000 +0900
@@ -449,6 +449,6 @@ struct file_operations discovery_seq_fop
 	.open           = discovery_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release,
 };
 #endif
diff -puN net/irda/iriap.c~net-seq_release-cleanup net/irda/iriap.c
--- linux-2.6.7/net/irda/iriap.c~net-seq_release-cleanup	2004-07-08 00:01:20.000000000 +0900
+++ linux-2.6.7-hirofumi/net/irda/iriap.c	2004-07-08 00:01:20.000000000 +0900
@@ -1093,7 +1093,7 @@ struct file_operations irias_seq_fops = 
 	.open           = irias_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release,
 };
 
 #endif /* PROC_FS */
diff -puN net/irda/ircomm/ircomm_core.c~net-seq_release-cleanup net/irda/ircomm/ircomm_core.c
--- linux-2.6.7/net/irda/ircomm/ircomm_core.c~net-seq_release-cleanup	2004-07-08 00:01:20.000000000 +0900
+++ linux-2.6.7-hirofumi/net/irda/ircomm/ircomm_core.c	2004-07-08 00:01:20.000000000 +0900
@@ -62,7 +62,7 @@ static struct file_operations ircomm_pro
 	.open           = ircomm_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release,
 };
 #endif /* CONFIG_PROC_FS */
 
_

-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
