From: Matt Bennett <matt.bennett@alliedtelesis.co.nz>
Subject: [PATCH] ip6_tunnel: Reduce log level in ip6_tnl_err() to debug
Date: Fri, 25 Sep 2015 11:01:47 +1200
Message-ID: <1443135707-14620-1-git-send-email-matt.bennett@alliedtelesis.co.nz>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, trivial@kernel.org,
	Matt Bennett <matt.bennett@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:39799 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107AbbIXXCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 19:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently error log messages in ip6_tnl_err are printed at 'warn'
level. This is different to other tunnel types which don't print
any messages. These log messages don't provide any information that
couldn't be deduced with networking tools. Also it can be annoying
to have one end of the tunnel go down and have the logs fill with
pointless messages such as "Path to destination invalid or inactive!".

This patch reduces the log level of these messages to 'dbg' level to
bring the visible behaviour into line with other tunnel types.

Signed-off-by: Matt Bennett <matt.bennett@alliedtelesis.co.nz>
---
 net/ipv6/ip6_tunnel.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index b0ab420..d04bed0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -510,14 +510,14 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		__u32 mtu;
 	case ICMPV6_DEST_UNREACH:
-		net_warn_ratelimited("%s: Path to destination invalid or inactive!\n",
-				     t->parms.name);
+		net_dbg_ratelimited("%s: Path to destination invalid or inactive!\n",
+				    t->parms.name);
 		rel_msg = 1;
 		break;
 	case ICMPV6_TIME_EXCEED:
 		if ((*code) == ICMPV6_EXC_HOPLIMIT) {
-			net_warn_ratelimited("%s: Too small hop limit or routing loop in tunnel!\n",
-					     t->parms.name);
+			net_dbg_ratelimited("%s: Too small hop limit or routing loop in tunnel!\n",
+					    t->parms.name);
 			rel_msg = 1;
 		}
 		break;
@@ -529,13 +529,13 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 		if (teli && teli == *info - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
 			if (tel->encap_limit == 0) {
-				net_warn_ratelimited("%s: Too small encapsulation limit or routing loop in tunnel!\n",
-						     t->parms.name);
+				net_dbg_ratelimited("%s: Too small encapsulation limit or routing loop in tunnel!\n",
+						    t->parms.name);
 				rel_msg = 1;
 			}
 		} else {
-			net_warn_ratelimited("%s: Recipient unable to parse tunneled packet!\n",
-					     t->parms.name);
+			net_dbg_ratelimited("%s: Recipient unable to parse tunneled packet!\n",
+					    t->parms.name);
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-- 
2.5.2
