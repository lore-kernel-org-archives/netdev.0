From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Fri, 29 Feb 2008 15:43:24 +0800
Message-ID: <47C7B79C.2010304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbYB2Hp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:45:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When proc_create() fail, we return -ENOMEM.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/atm/clip.c |    4 ++++
 net/atm/lec.c  |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index d30167c..57ed448 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -963,6 +963,10 @@ static int __init atm_clip_init(void)
 		struct proc_dir_entry *p;
 
 		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
+		if (!p) {
+			printk(KERN_ERR "Unable to initialize /proc/atm/arp\n");
+			return -ENOMEM;
+		}
 	}
 #endif
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 0e450d1..532965d 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1250,6 +1250,10 @@ static int __init lane_module_init(void)
 	struct proc_dir_entry *p;
 
 	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
+	if (!p) {
+		printk(KERN_ERR "Unable to initialize /proc/atm/lec\n");
+		return -ENOMEM;
+	}
 #endif
 
 	register_atm_ioctl(&lane_ioctl_ops);
-- 
WCN


