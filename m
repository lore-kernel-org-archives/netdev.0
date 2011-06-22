From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 5/5] vt: move vt notifiers into vt.h
Date: Wed, 22 Jun 2011 14:35:22 +0800
Message-ID: <1308724522-32461-6-git-send-email-amwang@redhat.com>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not necessary to share the same notifier.h.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
 include/linux/notifier.h |    9 ++-------
 include/linux/vt.h       |    7 +++++++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index ae8f7d9..d65746e 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -193,6 +193,8 @@ static inline int notifier_to_errno(int ret)
 
 /* Hibernation and suspend events are defined in include/linux/suspend.h. */
 
+/* Virtual Terminal events are defined in include/linux/vt.h. */
+
 #define NETLINK_URELEASE	0x0001	/* Unicast netlink socket released */
 
 /* Console keyboard events.
@@ -206,12 +208,5 @@ static inline int notifier_to_errno(int ret)
 
 extern struct blocking_notifier_head reboot_notifier_list;
 
-/* Virtual Terminal events. */
-#define VT_ALLOCATE		0x0001 /* Console got allocated */
-#define VT_DEALLOCATE		0x0002 /* Console will be deallocated */
-#define VT_WRITE		0x0003 /* A char got output */
-#define VT_UPDATE		0x0004 /* A bigger update occurred */
-#define VT_PREWRITE		0x0005 /* A char is about to be written to the console */
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_NOTIFIER_H */
diff --git a/include/linux/vt.h b/include/linux/vt.h
index d5dd0bc..30a8dd9 100644
--- a/include/linux/vt.h
+++ b/include/linux/vt.h
@@ -86,6 +86,13 @@ struct vt_setactivate {
 
 #ifdef __KERNEL__
 
+/* Virtual Terminal events. */
+#define VT_ALLOCATE		0x0001 /* Console got allocated */
+#define VT_DEALLOCATE		0x0002 /* Console will be deallocated */
+#define VT_WRITE		0x0003 /* A char got output */
+#define VT_UPDATE		0x0004 /* A bigger update occurred */
+#define VT_PREWRITE		0x0005 /* A char is about to be written to the console */
+
 #ifdef CONFIG_VT_CONSOLE
 
 extern int vt_kmsg_redirect(int new);
-- 
1.7.4.4
