From: tcharding <me@tobin.cc>
Subject: [PATCH 2/3] bridge: netfilter: checkpatch data type fixes
Date: Tue, 10 May 2016 11:26:57 +1000
Message-ID: <1462843618-21914-3-git-send-email-me@tobin.cc>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
Cc: Tobin C Harding <me@tobin.cc>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60060 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752723AbcEJB1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 21:27:12 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id CC58B20A27
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:27:11 -0400 (EDT)
In-Reply-To: <1462843618-21914-1-git-send-email-me@tobin.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobin C Harding <me@tobin.cc>

checkpatch produces data type 'checks'.

This patch amends them by changing, for example:
uint8_t -> u8

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 net/bridge/netfilter/ebt_stp.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 26a0859..9df943f 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -17,24 +17,24 @@
 #define BPDU_TYPE_TCN 0x80
 
 struct stp_header {
-	uint8_t dsap;
-	uint8_t ssap;
-	uint8_t ctrl;
-	uint8_t pid;
-	uint8_t vers;
-	uint8_t type;
+	u8 dsap;
+	u8 ssap;
+	u8 ctrl;
+	u8 pid;
+	u8 vers;
+	u8 type;
 };
 
 struct stp_config_pdu {
-	uint8_t flags;
-	uint8_t root[8];
-	uint8_t root_cost[4];
-	uint8_t sender[8];
-	uint8_t port[2];
-	uint8_t msg_age[2];
-	uint8_t max_age[2];
-	uint8_t hello_time[2];
-	uint8_t forward_delay[2];
+	u8 flags;
+	u8 root[8];
+	u8 root_cost[4];
+	u8 sender[8];
+	u8 port[2];
+	u8 msg_age[2];
+	u8 max_age[2];
+	u8 hello_time[2];
+	u8 forward_delay[2];
 };
 
 #define NR16(p) (p[0] << 8 | p[1])
@@ -44,8 +44,8 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 			      const struct stp_config_pdu *stpc)
 {
 	const struct ebt_stp_config_info *c;
-	uint16_t v16;
-	uint32_t v32;
+	u16 v16;
+	u32 v32;
 	int verdict, i;
 
 	c = &info->config;
@@ -125,7 +125,7 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct ebt_stp_info *info = par->matchinfo;
 	const struct stp_header *sp;
 	struct stp_header _stph;
-	const uint8_t header[6] = {0x42, 0x42, 0x03, 0x00, 0x00, 0x00};
+	const u8 header[6] = {0x42, 0x42, 0x03, 0x00, 0x00, 0x00};
 
 	sp = skb_header_pointer(skb, 0, sizeof(_stph), &_stph);
 	if (sp == NULL)
@@ -156,8 +156,8 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 static int ebt_stp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_stp_info *info = par->matchinfo;
-	const uint8_t bridge_ula[6] = {0x01, 0x80, 0xc2, 0x00, 0x00, 0x00};
-	const uint8_t msk[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	const u8 bridge_ula[6] = {0x01, 0x80, 0xc2, 0x00, 0x00, 0x00};
+	const u8 msk[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	const struct ebt_entry *e = par->entryinfo;
 
 	if (info->bitmask & ~EBT_STP_MASK || info->invflags & ~EBT_STP_MASK ||
-- 
2.8.2
