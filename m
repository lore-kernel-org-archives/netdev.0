From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] NFS: remove unused nfs4_find_client_no_ident function
Date: Fri, 20 Jan 2012 17:19:56 +0400
Message-ID: <20120120131855.13148.69517.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like this function survived after some cleanup patch without a reason.
Now it's not called or referenced and I believe, that it can be simply removed.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/client.c   |   27 ---------------------------
 fs/nfs/internal.h |    1 -
 2 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index df60d99..34c8d1c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1199,33 +1199,6 @@ error:
 /*
  * NFSv4.0 callback thread helper
  *
- * Find a client by IP address, protocol version, and minorversion
- *
- * Called from the pg_authenticate method. The callback identifier
- * is not used as it has not been decoded.
- *
- * Returns NULL if no such client
- */
-struct nfs_client *
-nfs4_find_client_no_ident(const struct sockaddr *addr)
-{
-	struct nfs_client *clp;
-
-	spin_lock(&nfs_client_lock);
-	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
-		if (nfs4_cb_match_client(addr, clp, 0) == false)
-			continue;
-		atomic_inc(&clp->cl_count);
-		spin_unlock(&nfs_client_lock);
-		return clp;
-	}
-	spin_unlock(&nfs_client_lock);
-	return NULL;
-}
-
-/*
- * NFSv4.0 callback thread helper
- *
  * Find a client by callback identifier
  */
 struct nfs_client *
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2b9836f..eda4cde4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -149,7 +149,6 @@ extern struct rpc_program nfs_program;
 
 extern void nfs_cleanup_cb_ident_idr(void);
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs4_find_client_no_ident(const struct sockaddr *);
 extern struct nfs_client *nfs4_find_client_ident(int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *);
