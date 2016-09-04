From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/9] fs/afs/vlocation: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 04 Sep 2016 22:03:05 +0100
Message-ID: <147302298519.28597.766505614863532593.stgit@warthog.procyon.org.uk>
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

The workqueue "afs_vlocation_update_worker" queues a single work item
&afs_vlocation_update and hence it doesn't require execution ordering.
Hence, alloc_workqueue has been used to replace the deprecated
create_singlethread_workqueue instance.

Since the workqueue is being used on a memory reclaim path, WQ_MEM_RECLAIM
flag has been set to ensure forward progress under memory pressure.

Since there are fixed number of work items, explicit concurrency
limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/vlocation.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 52976785a32c..45a86396fd2d 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -594,8 +594,8 @@ static void afs_vlocation_reaper(struct work_struct *work)
  */
 int __init afs_vlocation_update_init(void)
 {
-	afs_vlocation_update_worker =
-		create_singlethread_workqueue("kafs_vlupdated");
+	afs_vlocation_update_worker = alloc_workqueue("kafs_vlupdated",
+						      WQ_MEM_RECLAIM, 0);
 	return afs_vlocation_update_worker ? 0 : -ENOMEM;
 }
 
