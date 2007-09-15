From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Sat, 15 Sep 2007 09:15:43 -0400
Message-ID: <20070915131543.GB6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4614 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257AbXIONlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 09:41:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

A few more fixes targetted for 2.6.23, including a couple of warning fixes.

As usual, the individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem/

Thanks,

John

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Johannes Berg (3):
      cfg80211: fix initialisation if built-in
      net/mac80211/wme.c: fix sparse warning
      mac80211: fix initialisation when built-in

Satyam Sharma (1):
      net/wireless/sysfs.c: Shut up build warning

 net/mac80211/ieee80211.c      |    2 +-
 net/mac80211/rc80211_simple.c |    2 +-
 net/mac80211/wme.c            |    2 +-
 net/wireless/core.c           |    2 +-
 net/wireless/sysfs.c          |    2 ++
 5 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 7286c38..ff2172f 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -5259,7 +5259,7 @@ static void __exit ieee80211_exit(void)
 }
 
 
-module_init(ieee80211_init);
+subsys_initcall(ieee80211_init);
 module_exit(ieee80211_exit);
 
 MODULE_DESCRIPTION("IEEE 802.11 subsystem");
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index f6780d6..17b9f46 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -431,7 +431,7 @@ static void __exit rate_control_simple_exit(void)
 }
 
 
-module_init(rate_control_simple_init);
+subsys_initcall(rate_control_simple_init);
 module_exit(rate_control_simple_exit);
 
 MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 89ce815..7ab82b3 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -424,7 +424,7 @@ static int wme_qdiscop_init(struct Qdisc *qd, struct rtattr *opt)
 		skb_queue_head_init(&q->requeued[i]);
 		q->queues[i] = qdisc_create_dflt(qd->dev, &pfifo_qdisc_ops,
 						 qd->handle);
-		if (q->queues[i] == 0) {
+		if (!q->queues[i]) {
 			q->queues[i] = &noop_qdisc;
 			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
 		}
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 7eabd55..9771451 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -213,7 +213,7 @@ out_fail_notifier:
 out_fail_sysfs:
 	return err;
 }
-module_init(cfg80211_init);
+subsys_initcall(cfg80211_init);
 
 static void cfg80211_exit(void)
 {
diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index 88aaacd..2d5d225 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -52,12 +52,14 @@ static void wiphy_dev_release(struct device *dev)
 	cfg80211_dev_free(rdev);
 }
 
+#ifdef CONFIG_HOTPLUG
 static int wiphy_uevent(struct device *dev, char **envp,
 			int num_envp, char *buf, int size)
 {
 	/* TODO, we probably need stuff here */
 	return 0;
 }
+#endif
 
 struct class ieee80211_class = {
 	.name = "ieee80211",
-- 
John W. Linville
linville@tuxdriver.com
