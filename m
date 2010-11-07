From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Subject: [PATCH] SUNRPC: Simplify rpc_alloc_iostats by removing pointless
 local variable
Date: Sun, 7 Nov 2010 22:11:34 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

We can simplify net/sunrpc/stats.c::rpc_alloc_iostats() a bit by getting 
rid of the unneeded local variable 'new'.


Please CC me on replies.


Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
---
 stats.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git 
a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index f71a731..80df89d 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -115,9 +115,7 @@ EXPORT_SYMBOL_GPL(svc_seq_show);
  */
 struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt)
 {
-	struct rpc_iostats *new;
-	new = kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
-	return new;
+	return kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(rpc_alloc_iostats);
 


-- 
Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>             http://www.chaosbits.net/
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
