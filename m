From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] net/bridge: use kobject_put to release kobject in br_add_if error path
Date: Fri, 24 Jul 2009 17:06:32 +0800
Message-ID: <1248426392-30777-1-git-send-email-dfeng@redhat.com>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>
To: davem@davemloft.net, shemminger@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752221AbZGXJGm@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kobject_init_and_add will alloc memory for kobj->name, so in br_add_if
error path, simply use kobject_del will not free memory for kobj->name.
Fix by using kobject_put instead, kobject_put will internally calls
kobject_del and frees memory for kobj->name.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 net/bridge/br_if.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8a96672..eb404dc 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -424,7 +424,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
-	kobject_del(&p->kobj);
+	kobject_put(&p->kobj);
 err0:
 	dev_set_promiscuity(dev, -1);
 put_back:
-- 
1.6.2.5
