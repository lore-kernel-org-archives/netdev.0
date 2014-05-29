From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] bridge: fix the unbalanced promiscuous count when
 add_if failed
Date: Thu, 29 May 2014 10:15:30 +0800
Message-ID: <53869842.4060202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bridge@lists.linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:52726 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbaE2CRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 22:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As commit 2796d0c648c94("bridge: Automatically manage port
promiscuous mode."), make the add_if use dev_set_allmulti
instead of dev_set_promiscuous, so when add_if failed, we
should do dev_set_allmulti(dev, -1).

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/bridge/br_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 104a811..a08d2b8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -528,7 +528,7 @@ err2:
 	kobject_put(&p->kobj);
 	p = NULL; /* kobject_put frees */
 err1:
-	dev_set_promiscuity(dev, -1);
+	dev_set_allmulti(dev, -1);
 put_back:
 	dev_put(dev);
 	kfree(p);
-- 
1.8.4
