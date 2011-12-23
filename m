From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 3/3] NFS: don't mark freshly created callback sockets with
 XPT_CHNGBUF
Date: Fri, 23 Dec 2011 18:53:49 +0300
Message-ID: <20111223145349.847.70851.stgit@localhost6.localdomain6>
References: <20111223145145.847.46221.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111223145145.847.46221.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cleanup patch.
Check for XPT_CHNGBUF is done only for UPD sockets. NFS callbacks doesn't use
them.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index d81040a..1bf3e9f 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -278,8 +278,6 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		goto out_err;
 	}
 
-	svc_sock_update_bufs(serv);
-
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
 	cb_info->serv = serv;
 	cb_info->rqst = rqstp;
