From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] NET: sunrpc, remove unneeded NULL tests
Date: Wed, 27 Oct 2010 13:52:05 +0200
Message-ID: <1288180325-20009-1-git-send-email-jslaby@suse.cz>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found that req in xprt_reserve_xprt is dereferenced prior its
test to NULL. If that's the case, the checks are unnecessary, so
remove them.

The alternative is not to dereference it before the test. The patch
is to point out the problem, you have to decide.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
---
 net/sunrpc/xprt.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4c8f18a..5355c71 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -202,10 +202,8 @@ int xprt_reserve_xprt(struct rpc_task *task)
 		goto out_sleep;
 	}
 	xprt->snd_task = task;
-	if (req) {
-		req->rq_bytes_sent = 0;
-		req->rq_ntrans++;
-	}
+	req->rq_bytes_sent = 0;
+	req->rq_ntrans++;
 	return 1;
 
 out_sleep:
@@ -213,7 +211,7 @@ out_sleep:
 			task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req && req->rq_ntrans)
+	if (req->rq_ntrans)
 		rpc_sleep_on(&xprt->resend, task, NULL);
 	else
 		rpc_sleep_on(&xprt->sending, task, NULL);
-- 
1.7.3.1
