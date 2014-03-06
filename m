From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 6/6] tipc: don't log disabled
	tasklet handler errors
Date: Thu, 6 Mar 2014 14:40:21 +0100
Message-ID: <1394113221-30100-7-git-send-email-erik.hugne@ericsson.com>
References: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

Failure to schedule a TIPC tasklet with tipc_k_signal because the
tasklet handler is disabled is not an error. It means TIPC is
currently in the process of shutting down. We remove the error
logging in this case.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/handler.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index e4bc8a2..1fabf16 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -58,7 +58,6 @@ unsigned int tipc_k_signal(Handler routine, unsigned long argument)
 
 	spin_lock_bh(&qitem_lock);
 	if (!handler_enabled) {
-		pr_err("Signal request ignored by handler\n");
 		spin_unlock_bh(&qitem_lock);
 		return -ENOPROTOOPT;
 	}
-- 
1.8.3.2


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
