From: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 02/11] syslog_ns: add syslog_ns into user_namespace
Date: Wed, 7 Aug 2013 15:37:06 +0800
Message-ID: <1375861035-24320-3-git-send-email-rui.xiang@huawei.com>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375861035-24320-1-git-send-email-rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a syslog_ns pointer to user_namespace, and make
syslog_ns per user_namespace, not global.

Since syslog_ns is assigned to user_ns, we can have
full capabilities in new user_ns to create a new syslog_ns.

Signed-off-by: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/syslog.h         | 5 +++++
 include/linux/user_namespace.h | 1 +
 2 files changed, 6 insertions(+)

diff --git a/include/linux/syslog.h b/include/linux/syslog.h
index 425fafe..62ce47f 100644
--- a/include/linux/syslog.h
+++ b/include/linux/syslog.h
@@ -90,6 +90,11 @@ struct syslog_namespace {
 	size_t syslog_partial;
 
 	int dmesg_restrict;
+
+	/*
+	 * user namespace which owns this syslog ns.
+	 */
+	struct user_namespace *owner;
 };
 
 static inline struct syslog_namespace *get_syslog_ns(
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b6b215f..ce2de5b 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -28,6 +28,7 @@ struct user_namespace {
 	unsigned int		proc_inum;
 	bool			may_mount_sysfs;
 	bool			may_mount_proc;
+	struct syslog_namespace *syslog_ns;
 };
 
 extern struct user_namespace init_user_ns;
-- 
1.8.2.2
