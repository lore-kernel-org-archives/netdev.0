From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 9/9] fs/afs/flock: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 04 Sep 2016 22:03:25 +0100
Message-ID: <147302300563.28597.8226500849686976128.stgit@warthog.procyon.org.uk>
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

The workqueue "afs_lock_manager" queues work item &vnode->lock_work,
per vnode. Since there can be multiple vnodes and since their work items
can be executed concurrently, alloc_workqueue has been used to replace
the deprecated create_singlethread_workqueue instance.

The WQ_MEM_RECLAIM flag has been set to ensure forward progress under
memory pressure because the workqueue is being used on a memory reclaim
path.

Since there are fixed number of work items, explicit concurrency
limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/flock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/afs/flock.c b/fs/afs/flock.c
index d91a9c9cfbd0..3191dff2c156 100644
--- a/fs/afs/flock.c
+++ b/fs/afs/flock.c
@@ -36,8 +36,8 @@ static int afs_init_lock_manager(void)
 	if (!afs_lock_manager) {
 		mutex_lock(&afs_lock_manager_mutex);
 		if (!afs_lock_manager) {
-			afs_lock_manager =
-				create_singlethread_workqueue("kafs_lockd");
+			afs_lock_manager = alloc_workqueue("kafs_lockd",
+							   WQ_MEM_RECLAIM, 0);
 			if (!afs_lock_manager)
 				ret = -ENOMEM;
 		}
