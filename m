From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] NFS4: some cleanup in kernel thread creation
Date: Tue, 29 Mar 2011 13:06:38 +0400
Message-ID: <20110329090442.10367.54282.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kthread_run() macro allows to pass kthread name with parameters in printf
style. So, additinal array for kthread name is redundant and was removed.

Patch for 2.6.38
Found in 2.6.32

Signed-off-by: Stanislav Kinsbursky <skinsbursky@openvz.org>

---
 fs/nfs/callback.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..9e5220f 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -250,7 +250,6 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 	struct svc_rqst *rqstp;
 	int (*callback_svc)(void *vrqstp);
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
-	char svc_name[12];
 	int ret = 0;
 	int minorversion_setup;
 
@@ -280,10 +279,10 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 
 	svc_sock_update_bufs(serv);
 
-	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
 	cb_info->serv = serv;
 	cb_info->rqst = rqstp;
-	cb_info->task = kthread_run(callback_svc, cb_info->rqst, svc_name);
+	cb_info->task = kthread_run(callback_svc, cb_info->rqst,
+					"nfsv4.%u-svc", minorversion);
 	if (IS_ERR(cb_info->task)) {
 		ret = PTR_ERR(cb_info->task);
 		svc_exit_thread(cb_info->rqst);
