From: jamal <hadi@cyberus.ca>
Subject: PATCH: explicit typing WAS(Re: PATCH: rtnetlink explicit flags
	setting
Date: Thu, 02 Jun 2005 09:04:52 -0400
Message-ID: <1117717493.6050.29.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050531.144338.112623594.davem@davemloft.net>
	 <20050531222646.GK15391@postel.suug.ch>
	 <20050531.153125.95894437.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-MNGFh9ieSNAM2tZgwH9J"
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050531.153125.95894437.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-MNGFh9ieSNAM2tZgwH9J
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-31-05 at 15:31 -0700, David S. Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 1 Jun 2005 00:26:46 +0200
> 
> > > Please use explicit "unsigned int flags" instead of "unsigned flags".
> > 
> > I converted this already in the two patches later in the thread.
> 
> I see, thanks for pointing this out.
> 

If you want to do it right, it should be a u16 actually ;->

In any case since we are being gracious - lets fix where i cutnpasted it
from using TheLinuxWay ;->


-------------
This patch converts "unsigned flags" to use more explict types like u16
instead and incrementally introduces NLMSG_NEW().
 
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca> 


cheers,
jamal

--=-MNGFh9ieSNAM2tZgwH9J
Content-Disposition: attachment; filename=expl_p
Content-Type: text/plain; name=expl_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

net/ipv6/addrconf.c: needs update
net/sched/act_api.c: needs update
net/sched/cls_api.c: needs update
net/sched/sch_api.c: needs update
Index: net/ipv6/addrconf.c
===================================================================
--- faa2ccd541211d62ece040534da95da9476d4f14/net/ipv6/addrconf.c  (mode:100644)
+++ uncommitted/net/ipv6/addrconf.c  (mode:100644)
@@ -131,7 +131,7 @@
 
 static int addrconf_ifdown(struct net_device *dev, int how);
 
-static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
@@ -491,7 +491,7 @@
 
 static struct inet6_ifaddr *
 ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
-	      int scope, unsigned flags)
+	      int scope, u32 flags)
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
@@ -1319,7 +1319,7 @@
 
 static void
 addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
-		      unsigned long expires, unsigned flags)
+		      unsigned long expires, u32 flags)
 {
 	struct in6_rtmsg rtmsg;
 
@@ -2228,7 +2228,7 @@
 /*
  *	Duplicate Address Detection
  */
-static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
@@ -2670,7 +2670,7 @@
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
-				u32 pid, u32 seq, int event, unsigned flags)
+				u32 pid, u32 seq, int event, u16 flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
Index: net/sched/act_api.c
===================================================================
--- faa2ccd541211d62ece040534da95da9476d4f14/net/sched/act_api.c  (mode:100644)
+++ uncommitted/net/sched/act_api.c  (mode:100644)
@@ -428,15 +428,15 @@
 
 static int
 tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
-             unsigned flags, int event, int bind, int ref)
+             u16 flags, int event, int bind, int ref)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb->tail;
 	struct rtattr *x;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*t));
-	nlh->nlmsg_flags = flags;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
+
 	t = NLMSG_DATA(nlh);
 	t->tca_family = AF_UNSPEC;
 	
@@ -669,7 +669,7 @@
 }
 
 static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
-                          unsigned flags)
+                          u16 flags)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
@@ -684,8 +684,7 @@
 
 	b = (unsigned char *)skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*t));
-	nlh->nlmsg_flags = flags;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
 	t = NLMSG_DATA(nlh);
 	t->tca_family = AF_UNSPEC;
 	
Index: net/sched/cls_api.c
===================================================================
--- faa2ccd541211d62ece040534da95da9476d4f14/net/sched/cls_api.c  (mode:100644)
+++ uncommitted/net/sched/cls_api.c  (mode:100644)
@@ -322,14 +322,13 @@
 
 static int
 tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp, unsigned long fh,
-	      u32 pid, u32 seq, unsigned flags, int event)
+	      u32 pid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
-	nlh->nlmsg_flags = flags;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm_ifindex = tp->q->dev->ifindex;
Index: net/sched/sch_api.c
===================================================================
--- faa2ccd541211d62ece040534da95da9476d4f14/net/sched/sch_api.c  (mode:100644)
+++ uncommitted/net/sched/sch_api.c  (mode:100644)
@@ -760,15 +760,14 @@
 }
 
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
-			 u32 pid, u32 seq, unsigned flags, int event)
+			 u32 pid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 	struct gnet_dump d;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
-	nlh->nlmsg_flags = flags;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm_ifindex = q->dev->ifindex;
@@ -997,7 +996,7 @@
 
 static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 			  unsigned long cl,
-			  u32 pid, u32 seq, unsigned flags, int event)
+			  u32 pid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -1005,8 +1004,7 @@
 	struct gnet_dump d;
 	struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
-	nlh->nlmsg_flags = flags;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm_ifindex = q->dev->ifindex;

--=-MNGFh9ieSNAM2tZgwH9J--
