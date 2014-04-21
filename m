From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/11] tipc: use bearer_disable
	to disable bearer in tipc_l2_device_event
Date: Mon, 21 Apr 2014 10:55:50 +0800
Message-ID: <1398048952-7825-10-git-send-email-ying.xue@windriver.com>
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

As bearer pointer is known in tipc_l2_device_event(), it's unnecessary
to search it again in tipc_disable_bearer(). If tipc_disable_bearer()
is replaced with bearer_disable() in tipc_l2_device_event(), this will
help us save a bit time when bearer is disabled.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 402e994..44fd22a 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -606,7 +606,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
-		tipc_disable_bearer(b_ptr->name);
+		bearer_disable(b_ptr, false);
 		break;
 	}
 	return NOTIFY_OK;
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
