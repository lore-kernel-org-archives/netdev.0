From: Patrick McHardy <kaber@trash.net>
Subject: netlink 25/31: constify nlmsghdr arguments
Date: Thu, 10 Sep 2009 18:12:19 +0200 (MEST)
Message-ID: <20090910161214.31179.78640.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 3a6c2b419b7768703cfb2cabdb894517c5065e33
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Aug 25 16:07:40 2009 +0200

    netlink: constify nlmsghdr arguments
    
    Consitfy nlmsghdr arguments to a couple of functions as preparation
    for the next patch, which will constify the netlink message data in
    all nfnetlink users.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 5ba398e..0fbecbb 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -217,12 +217,13 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
 struct netlink_callback
 {
-	struct sk_buff	*skb;
-	struct nlmsghdr	*nlh;
-	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
-	int		(*done)(struct netlink_callback *cb);
-	int		family;
-	long		args[6];
+	struct sk_buff		*skb;
+	const struct nlmsghdr	*nlh;
+	int			(*dump)(struct sk_buff * skb,
+					struct netlink_callback *cb);
+	int			(*done)(struct netlink_callback *cb);
+	int			family;
+	long			args[6];
 };
 
 struct netlink_notify
@@ -258,7 +259,7 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 	NLMSG_NEW(skb, pid, seq, type, len, 0)
 
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-			      struct nlmsghdr *nlh,
+			      const struct nlmsghdr *nlh,
 			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
 			      int (*done)(struct netlink_callback*));
 
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 007bdb0..a63b219 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -365,7 +365,7 @@ static inline struct nlmsghdr *nlmsg_next(struct nlmsghdr *nlh, int *remaining)
  *
  * See nla_parse()
  */
-static inline int nlmsg_parse(struct nlmsghdr *nlh, int hdrlen,
+static inline int nlmsg_parse(const struct nlmsghdr *nlh, int hdrlen,
 			      struct nlattr *tb[], int maxtype,
 			      const struct nla_policy *policy)
 {
@@ -414,7 +414,7 @@ static inline int nlmsg_validate(struct nlmsghdr *nlh, int hdrlen, int maxtype,
  *
  * Returns 1 if a report back to the application is requested.
  */
-static inline int nlmsg_report(struct nlmsghdr *nlh)
+static inline int nlmsg_report(const struct nlmsghdr *nlh)
 {
 	return !!(nlh->nlmsg_flags & NLM_F_ECHO);
 }
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3c1895e..85ba560 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -14,7 +14,7 @@ extern void	rtnl_register(int protocol, int msgtype,
 extern int	rtnl_unregister(int protocol, int msgtype);
 extern void	rtnl_unregister_all(int protocol);
 
-static inline int rtnl_msg_family(struct nlmsghdr *nlh)
+static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
 {
 	if (nlmsg_len(nlh) >= sizeof(struct rtgenmsg))
 		return ((struct rtgenmsg *) nlmsg_data(nlh))->rtgen_family;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index da3163d..d0ff382 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1705,7 +1705,7 @@ errout:
 }
 
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-		       struct nlmsghdr *nlh,
+		       const struct nlmsghdr *nlh,
 		       int (*dump)(struct sk_buff *skb,
 				   struct netlink_callback *),
 		       int (*done)(struct netlink_callback *))
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 9d03cc3..2dfb3e7 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1011,7 +1011,7 @@ replay:
 }
 
 static struct nlattr *
-find_dump_kind(struct nlmsghdr *n)
+find_dump_kind(const struct nlmsghdr *n)
 {
 	struct nlattr *tb1, *tb2[TCA_ACT_MAX+1];
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
