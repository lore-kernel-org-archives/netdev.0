From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 5/5] SUNRPC: kernel PipeFS mount point creation routines
	removed
Date: Tue, 29 Nov 2011 13:10:46 +0300
Message-ID: <20111129091046.20730.69514.stgit@localhost6.localdomain6>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes static rpc_mnt variable and its creation and destruction
routines, because they are not used anymore.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 --
 net/sunrpc/rpc_pipe.c              |   21 ---------------------
 2 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 7eb0160..a28d2de 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -90,8 +90,6 @@ void rpc_destroy_pipe_data(struct rpc_pipe *pipe);
 extern struct dentry *rpc_mkpipe_dentry(struct dentry *, const char *, void *,
 					struct rpc_pipe *);
 extern int rpc_unlink(struct dentry *);
-extern struct vfsmount *rpc_get_mount(void);
-extern void rpc_put_mount(void);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e194e32..4b1d042 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -18,7 +18,6 @@
 #include <linux/kernel.h>
 
 #include <asm/ioctls.h>
-#include <linux/fs.h>
 #include <linux/poll.h>
 #include <linux/wait.h>
 #include <linux/seq_file.h>
@@ -37,9 +36,6 @@
 
 #define NET_NAME(net)	((net == &init_net) ? " (init_net)" : "")
 
-static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
-
 static struct file_system_type rpc_pipe_fs_type;
 
 
@@ -430,23 +426,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-struct vfsmount *rpc_get_mount(void)
-{
-	int err;
-
-	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mnt, &rpc_mount_count);
-	if (err != 0)
-		return ERR_PTR(err);
-	return rpc_mnt;
-}
-EXPORT_SYMBOL_GPL(rpc_get_mount);
-
-void rpc_put_mount(void)
-{
-	simple_release_fs(&rpc_mnt, &rpc_mount_count);
-}
-EXPORT_SYMBOL_GPL(rpc_put_mount);
-
 static int rpc_delete_dentry(const struct dentry *dentry)
 {
 	return 1;
