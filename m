From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH resend] rhashtable: initialize all rhashtable walker members
Date: Mon, 23 Feb 2015 04:35:06 -0500
Message-ID: <1424684106-5405-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: herbert@gondor.apana.org.au, tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f2dba9c6ff ("rhashtable: Introduce rhashtable_walk_*") forgot to
initialize the members of struct rhashtable_walker after allocating it, which
caused an undefined value for 'resize' which is used later on.

Fixes: f2dba9c6ff ("rhashtable: Introduce rhashtable_walk_*")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/rhashtable.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9cc4c4a..030484c 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -894,6 +894,9 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
 	if (!iter->walker)
 		return -ENOMEM;
 
+	INIT_LIST_HEAD(&iter->walker->list);
+	iter->walker->resize = false;
+
 	mutex_lock(&ht->mutex);
 	list_add(&iter->walker->list, &ht->walkers);
 	mutex_unlock(&ht->mutex);
-- 
1.7.10.4
