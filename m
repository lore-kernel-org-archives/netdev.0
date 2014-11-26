From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] bridge: Validate IFLA_BRIDGE_FLAGS attribute length
Date: Wed, 26 Nov 2014 13:42:16 +0100
Message-ID: <fbc927e13920d0c5b549bab74d50a83c6bd31408.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56824 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaKZMm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:28 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Payload is currently accessed blindly and may exceed valid message
boundaries.

Fixes: 407af3299 ("bridge: Add netlink interface to configure vlans on bridge ports")
Cc: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/rtnetlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..5a853f8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2798,6 +2798,9 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (br_spec) {
 		nla_for_each_nested(attr, br_spec, rem) {
 			if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
+				if (nla_len(attr) < sizeof(flags))
+					return -EINVAL;
+
 				have_flags = true;
 				flags = nla_get_u16(attr);
 				break;
@@ -2868,6 +2871,9 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (br_spec) {
 		nla_for_each_nested(attr, br_spec, rem) {
 			if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
+				if (nla_len(attr) < sizeof(flags))
+					return -EINVAL;
+
 				have_flags = true;
 				flags = nla_get_u16(attr);
 				break;
-- 
1.9.3
