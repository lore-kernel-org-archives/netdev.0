From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Expose rtnl_link_ops_get()
Date: Wed, 20 Jan 2010 07:01:11 -0800
Message-ID: <1263999673-11279-2-git-send-email-danms@us.ibm.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263999673-11279-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/net/rtnetlink.h |    1 +
 net/core/rtnetlink.c    |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index c3aa044..a165769 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -82,6 +82,7 @@ extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
 
+extern const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind);
 extern struct net_device *rtnl_create_link(struct net *net, char *ifname,
 		const struct rtnl_link_ops *ops, struct nlattr *tb[]);
 extern const struct nla_policy ifla_policy[IFLA_MAX+1];
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb42873..2b2150c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -325,7 +325,7 @@ void rtnl_link_unregister(struct rtnl_link_ops *ops)
 
 EXPORT_SYMBOL_GPL(rtnl_link_unregister);
 
-static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
+const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
 {
 	const struct rtnl_link_ops *ops;
 
-- 
1.6.2.5
