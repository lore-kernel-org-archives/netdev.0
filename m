From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 7/7][RFC] netfilter: xt_IDLETIMER: Rename INTERFACE to LABEL in netlink notification.
Date: Fri, 21 Sep 2012 22:10:53 -0400
Message-ID: <1348279853-44499-8-git-send-email-john.stultz@linaro.org>
References: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Cc: Ashish Sharma <ashishsharma@google.com>, netdev@vger.kernel.org,
	JP Abgrall <jpa@google.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ashish Sharma <ashishsharma@google.com>

Rename INTERFACE to LABEL in netlink notification.

Cc: netdev@vger.kernel.org
Cc: JP Abgrall <jpa@google.com>
Cc: Ashish Sharma <ashishsharma@google.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Ashish Sharma <ashishsharma@google.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 net/netfilter/xt_IDLETIMER.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index df91e26..f4ba863 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -68,15 +68,15 @@ static DEFINE_MUTEX(list_mutex);
 
 static struct kobject *idletimer_tg_kobj;
 
-static void notify_netlink_uevent(const char *iface, struct idletimer_tg *timer)
+static void notify_netlink_uevent(const char *label, struct idletimer_tg *timer)
 {
-	char iface_msg[NLMSG_MAX_SIZE];
+	char label_msg[NLMSG_MAX_SIZE];
 	char state_msg[NLMSG_MAX_SIZE];
-	char *envp[] = { iface_msg, state_msg, NULL };
+	char *envp[] = { label_msg, state_msg, NULL };
 	int res;
 
-	res = snprintf(iface_msg, NLMSG_MAX_SIZE, "INTERFACE=%s",
-		       iface);
+	res = snprintf(label_msg, NLMSG_MAX_SIZE, "LABEL=%s",
+		       label);
 	if (NLMSG_MAX_SIZE <= res) {
 		pr_err("message too long (%d)", res);
 		return;
@@ -87,7 +87,7 @@ static void notify_netlink_uevent(const char *iface, struct idletimer_tg *timer)
 		pr_err("message too long (%d)", res);
 		return;
 	}
-	pr_debug("putting nlmsg: <%s> <%s>\n", iface_msg, state_msg);
+	pr_debug("putting nlmsg: <%s> <%s>\n", label_msg, state_msg);
 	kobject_uevent_env(idletimer_tg_kobj, KOBJ_CHANGE, envp);
 	return;
 
-- 
1.7.9.5
