From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 4/5 v2] sctp: remove useless arguments from get_saddr()
 call
Date: Wed, 27 Apr 2011 15:53:20 +0800
Message-ID: <4DB7CB70.8020605@cn.fujitsu.com>
References: <4DB7C73D.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60706 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab1D0Hxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 03:53:37 -0400
In-Reply-To: <4DB7C73D.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

There is no point in passing a destination address to
a get_saddr() call.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    1 -
 net/sctp/ipv6.c            |    5 +----
 net/sctp/protocol.c        |    1 -
 net/sctp/transport.c       |    2 +-
 4 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 1d465d6..bb2f43b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -571,7 +571,6 @@ struct sctp_af {
 					 struct sock *sk);
 	void		(*get_saddr)	(struct sctp_sock *sk,
 					 struct sctp_transport *t,
-					 union sctp_addr *daddr,
 					 struct flowi *fl);
 	void		(*copy_addrlist) (struct list_head *,
 					  struct net_device *);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 593c801..a1913a4 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -365,15 +365,12 @@ static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
  */
 static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			      struct sctp_transport *t,
-			      union sctp_addr *daddr,
 			      struct flowi *fl)
 {
 	struct flowi6 *fl6 = &fl->u.ip6;
 	union sctp_addr *saddr = &t->saddr;
 
-	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%pI6 ",
-			  __func__, t->asoc, t->dst, &daddr->v6.sin6_addr);
-
+	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p\n", __func__, t->asoc, t->dst);
 
 	if (t->dst) {
 		saddr->v6.sin6_family = AF_INET6;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 3421645..68b4c43 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -562,7 +562,6 @@ out:
  */
 static void sctp_v4_get_saddr(struct sctp_sock *sk,
 			      struct sctp_transport *t,
-			      union sctp_addr *daddr,
 			      struct flowi *fl)
 {
 	union sctp_addr *saddr = &t->saddr;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 2544b9b..1fbb920 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -284,7 +284,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
 	else
-		af->get_saddr(opt, transport, daddr, &fl);
+		af->get_saddr(opt, transport, &fl);
 
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {
 		return;
-- 
1.6.5.2


