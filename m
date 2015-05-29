From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH v2] netevent: remove automatic variable in register_netevent_notifier()
Date: Fri, 29 May 2015 01:02:08 +0000
Message-ID: <1432861328-227197-1-git-send-email-long.wanglong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <long.wanglong@huawei.com>, <linux-kernel@vger.kernel.org>,
	<peifeiyue@huawei.com>, <wanglong@laoqinren.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove automatic variable 'err' in register_netevent_notifier() and
return the result of atomic_notifier_chain_register() directly.

Signed-off-by: Wang Long <long.wanglong@huawei.com>
---
 net/core/netevent.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/core/netevent.c b/net/core/netevent.c
index f17ccd2..8b3bc4f 100644
--- a/net/core/netevent.c
+++ b/net/core/netevent.c
@@ -31,10 +31,7 @@ static ATOMIC_NOTIFIER_HEAD(netevent_notif_chain);
  */
 int register_netevent_notifier(struct notifier_block *nb)
 {
-	int err;
-
-	err = atomic_notifier_chain_register(&netevent_notif_chain, nb);
-	return err;
+	return atomic_notifier_chain_register(&netevent_notif_chain, nb);
 }
 EXPORT_SYMBOL_GPL(register_netevent_notifier);
 
-- 
1.8.3.4
