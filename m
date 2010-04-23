From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: nfs41: potential null deref in xprt_reserve_xprt()?
Date: Fri, 23 Apr 2010 14:00:13 +0200
Message-ID: <20100423120013.GF29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: iyer-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'm going through some Smatch results and had a question.  

Until commit 343952fa5a: "nfs41: Get the rpc_xprt * from the rpc_rqst 
instead of the rpc_clnt." we assumed that "task->tk_rqstp" can be NULL.  
But that patch dereferences it unconditionally.

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 0eea2bf..c144611 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -195,8 +195,8 @@ EXPORT_SYMBOL_GPL(xprt_load_transport);
  */
 int xprt_reserve_xprt(struct rpc_task *task)
 {
-       struct rpc_xprt *xprt = task->tk_xprt;
        struct rpc_rqst *req = task->tk_rqstp;
+       struct rpc_xprt *xprt = req->rq_xprt;
	                        ^^^^^^^^^^^^^

Can "req" be null here?  The patch is a year old, so presumably it
isn't null very often.

If you would like, I can remove the checks for null from the rest of the
function.

regards,
dan carpenter
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
