From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 7/7] net/sunrpc/clnt.c: Convert sprintf_symbol to %ps
Date: Fri,  5 Nov 2010 16:12:40 -0700
Message-ID: <1288998760-11775-8-git-send-email-joe@perches.com>
References: <1288998760-11775-1-git-send-email-joe@perches.com>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1288998760-11775-1-git-send-email-joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/sunrpc/clnt.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..0c3d395 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1824,23 +1824,15 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
 			  const struct rpc_task *task)
 {
 	const char *rpc_waitq = "none";
-	char *p, action[KSYM_SYMBOL_LEN];
 
 	if (RPC_IS_QUEUED(task))
 		rpc_waitq = rpc_qname(task->tk_waitqueue);
 
-	/* map tk_action pointer to a function name; then trim off
-	 * the "+0x0 [sunrpc]" */
-	sprint_symbol(action, (unsigned long)task->tk_action);
-	p = strchr(action, '+');
-	if (p)
-		*p = '\0';
-
-	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:%s\n",
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%ps q:%s\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
 		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
-		action, rpc_waitq);
+		task->tk_action, rpc_waitq);
 }
 
 void rpc_show_tasks(void)
-- 
1.7.3.2.146.gca209

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
