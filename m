From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/9] fs/afs/callback: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 04 Sep 2016 22:03:18 +0100
Message-ID: <147302299888.28597.17890220162942786973.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

The workqueue "afs_callback_update_worker" queues multiple work items
viz  &vnode->cb_broken_work, &server->cb_break_work which require strict
execution ordering. Hence, an ordered dedicated workqueue has been used.

Since the workqueue is being used on a memory reclaim path, WQ_MEM_RECLAIM
has been set to ensure forward progress under memory pressure.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/callback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 7ef637d7f3a5..1e9d2f84e5b5 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -461,8 +461,8 @@ static void afs_callback_updater(struct work_struct *work)
  */
 int __init afs_callback_update_init(void)
 {
-	afs_callback_update_worker =
-		create_singlethread_workqueue("kafs_callbackd");
+	afs_callback_update_worker = alloc_ordered_workqueue("kafs_callbackd",
+							     WQ_MEM_RECLAIM);
 	return afs_callback_update_worker ? 0 : -ENOMEM;
 }
 
