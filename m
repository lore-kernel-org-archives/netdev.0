From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 3/5] tipc: purge links when
	bearer is disabled
Date: Thu, 26 Feb 2015 07:43:28 +0100
Message-ID: <1424933010-31003-4-git-send-email-erik.hugne@ericsson.com>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
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

If a bearer is disabled by manual intervention, all links over that
bearer should be purged, indicated with the 'shutting_down' flag.
Otherwise tipc will get confused if a new bearer is enabled using
a different media type.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 48852c2..af6deeb 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -742,7 +742,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	bearer_disable(net, bearer, false);
+	bearer_disable(net, bearer, true);
 	rtnl_unlock();
 
 	return 0;
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
