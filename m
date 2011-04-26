From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 4/7] sctp: remove useless arguments from get_saddr()
 call
Date: Tue, 26 Apr 2011 11:47:39 +0800
Message-ID: <4DB6405B.2060200@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54896 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758005Ab1DZDrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:47:52 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

There is no point in passing a destination address to
a get_saddr() call.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/structs.h |    1 -
 net/sctp/ipv6.c            |    2 +-
 net/sctp/protocol.c        |    1 -
 net/sctp/transport.c       |    2 +-
 4 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a98d36f..cd4aea9 100644
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
index 74fe28c..31b6f35 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -392,11 +392,11 @@ static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
  */
 static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			      struct sctp_transport *t,
-			      union sctp_addr *daddr,
 			      struct flowi *fl)
 {
 	struct flowi6 *fl6 = &fl->u.ip6;
 	union sctp_addr *saddr = &t->saddr;
+	union sctp_addr *daddr = &t->ipaddr;
 
 	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%pI6 ",
 			  __func__, t->asoc, t->dst, &daddr->v6.sin6_addr);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 7be5df6..92b8b91 100644
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


