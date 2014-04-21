From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/11] tipc: use RTNL lock to
	protect tipc_net_stop routine
Date: Mon, 21 Apr 2014 10:55:44 +0800
Message-ID: <1398048952-7825-4-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

As the tipc network initialization(ie, tipc_net_start routine) is
under RTNL protection, its corresponding deinitialization part(ie,
tipc_net_stop routine) should be protected by RTNL too.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/net.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 4c564eb..24d2d21 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -195,11 +195,13 @@ void tipc_net_stop(void)
 		return;
 
 	tipc_nametbl_withdraw(TIPC_CFG_SRV, tipc_own_addr, 0, tipc_own_addr);
+	rtnl_lock();
 	write_lock_bh(&tipc_net_lock);
 	tipc_bearer_stop();
 	tipc_bclink_stop();
 	tipc_node_stop();
 	write_unlock_bh(&tipc_net_lock);
+	rtnl_unlock();
 
 	pr_info("Left network mode\n");
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
