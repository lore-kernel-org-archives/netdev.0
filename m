From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/9] fs/afs/rxrpc: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 04 Sep 2016 22:03:12 +0100
Message-ID: <147302299214.28597.17964402805414984241.stgit@warthog.procyon.org.uk>
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

The workqueue "afs_async_calls" queues work item
&call->async_work per afs_call. Since there could be multiple calls and since
these calls can be run concurrently, alloc_workqueue has been used to replace
the deprecated create_singlethread_workqueue instance.

The WQ_MEM_RECLAIM flag has been set to ensure forward progress under
memory pressure because the workqueue is being used on a memory reclaim
path.

Since there are fixed number of work items, explicit concurrency
limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 244896baf241..37608be52abd 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -76,7 +76,7 @@ int afs_open_socket(void)
 	_enter("");
 
 	ret = -ENOMEM;
-	afs_async_calls = create_singlethread_workqueue("kafsd");
+	afs_async_calls = alloc_workqueue("kafsd", WQ_MEM_RECLAIM, 0);
 	if (!afs_async_calls)
 		goto error_0;
 
