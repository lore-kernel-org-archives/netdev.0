From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/25] NFS: Change cb_recallargs to pass "struct
	sockaddr *"	instead of sockaddr_in
Date: Tue, 13 Nov 2007 13:31:53 -0500
Message-ID: <20071113183153.5087.60185.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Change the addr field in the cb_recallargs struct to a "struct sockaddr *"
to support IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/callback.h      |    2 +-
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index ec0ffd9..bb25d21 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -53,7 +53,7 @@ struct cb_getattrres {
 };
 
 struct cb_recallargs {
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2a1b14f..00082cf 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 3eda1bc..c63eb72 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -188,7 +188,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 *p;
 	__be32 status;
 
-	args->addr = svc_addr_in(rqstp);
+	args->addr = svc_addr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
