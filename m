From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 2/3] net: dev: fix build failed when procfs is disabled
Date: Tue, 19 Feb 2013 18:43:11 +0800
Message-ID: <1361270592-19492-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: davem@davemloft.net, Gao feng <gaofeng@cn.fujitsu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:42094 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754903Ab3BSKmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 05:42:40 -0500
In-Reply-To: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 900ff8c6321418dafa03c22e215cb9646a2541b9
"net: move procfs code to net/core/net-procfs.c"
missed define dev_mcast_init when CONFIG_PROC
isn't configured.

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netdevice.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f111b4f..91f6c7b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2693,8 +2693,10 @@ extern void		net_disable_timestamp(void);
 
 #ifdef CONFIG_PROC_FS
 extern int __init dev_proc_init(void);
+extern void __init dev_mcast_init(void);
 #else
 #define dev_proc_init() 0
+#define dev_mcast_init() {}
 #endif
 
 extern int netdev_class_create_file(struct class_attribute *class_attr);
-- 
1.7.11.7
