From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] rtnetlink: fix frame size warning in rtnl_fill_ifinfo
Date: Mon, 16 Nov 2015 12:05:03 +0100
Message-ID: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49505 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbbKPLFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 06:05:13 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id D37D22071B
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 06:05:12 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the following warning:

  CC      net/core/rtnetlink.o
net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=80=99:
net/core/rtnetlink.c:1308:1: warning: the frame size of 2864 bytes is l=
arger than 2048 bytes [-Wframe-larger-than=3D]
 }
 ^

By declaring the huge stack allocations as static. We can do so because
we hold rtnl.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/rtnetlink.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 504bd17..4bee37e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1051,7 +1051,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, =
struct net_device *dev,
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	struct rtnl_link_stats64 temp;
+	static struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
@@ -1153,16 +1153,16 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb=
, struct net_device *dev,
 		if (!vfinfo)
 			goto nla_put_failure;
 		for (i =3D 0; i < num_vfs; i++) {
-			struct ifla_vf_info ivi;
-			struct ifla_vf_mac vf_mac;
-			struct ifla_vf_vlan vf_vlan;
-			struct ifla_vf_rate vf_rate;
-			struct ifla_vf_tx_rate vf_tx_rate;
-			struct ifla_vf_spoofchk vf_spoofchk;
-			struct ifla_vf_link_state vf_linkstate;
-			struct ifla_vf_rss_query_en vf_rss_query_en;
-			struct ifla_vf_stats vf_stats;
-			struct ifla_vf_trust vf_trust;
+			static struct ifla_vf_info ivi;
+			static struct ifla_vf_mac vf_mac;
+			static struct ifla_vf_vlan vf_vlan;
+			static struct ifla_vf_rate vf_rate;
+			static struct ifla_vf_tx_rate vf_tx_rate;
+			static struct ifla_vf_spoofchk vf_spoofchk;
+			static struct ifla_vf_link_state vf_linkstate;
+			static struct ifla_vf_rss_query_en vf_rss_query_en;
+			static struct ifla_vf_stats vf_stats;
+			static struct ifla_vf_trust vf_trust;
=20
 			/*
 			 * Not all SR-IOV capable drivers support the
--=20
2.5.0
