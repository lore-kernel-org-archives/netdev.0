From: <zhanghonghui@huawei.com>
Subject: [PATCH] netlink: cleanup the unnecessary return value check
Date: Tue, 23 Oct 2012 16:21:23 +0800
Message-ID: <1350980483-4992-1-git-send-email-zhanghonghui@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <edumazet@google.com>,
	Hans Zhang <zhanghonghui@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Zhang <zhanghonghui@huawei.com>

It's no needed to check the return value of tab since the NULL situation
has been handled already, and the rtnl_msg_handlers[PF_UNSPEC] has been
initialized as non-NULL during the rtnetlink_init().

Signed-off-by: Hans Zhang <zhanghonghui@huawei.com>
---
 net/core/rtnetlink.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 76d4c2c..64fe3cc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -128,7 +128,7 @@ static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
 	if (tab == NULL || tab[msgindex].doit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
-	return tab ? tab[msgindex].doit : NULL;
+	return tab[msgindex].doit;
 }
 
 static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
@@ -143,7 +143,7 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
 	if (tab == NULL || tab[msgindex].dumpit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
-	return tab ? tab[msgindex].dumpit : NULL;
+	return tab[msgindex].dumpit;
 }
 
 static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
@@ -158,7 +158,7 @@ static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
 	if (tab == NULL || tab[msgindex].calcit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
-	return tab ? tab[msgindex].calcit : NULL;
+	return tab[msgindex].calcit;
 }
 
 /**
-- 
1.7.1
