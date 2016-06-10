From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH] tipc: fix potential null pointer dereference in the nla_data
 function
Date: Fri, 10 Jun 2016 10:26:59 +0800
Message-ID: <a692a179-6f59-fdbb-9c49-e943677fce43@gmail.com>
References: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com, ying.xue@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33703 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbcFJC1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 22:27:07 -0400
Received: by mail-pa0-f65.google.com with SMTP id di3so3965194pab.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 19:27:07 -0700 (PDT)
In-Reply-To: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before calling the nla_data function, make sure the argument is not null.
Fix potential null pointer dereference vulnerability for this.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
 net/tipc/netlink_compat.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index f795b1d..efbba26 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -356,6 +356,9 @@ static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
 	if (err)
 		return err;
 
+	if (!bearer[TIPC_NLA_BEARER_NAME])
+		return -EINVAL;
+
 	return tipc_add_tlv(msg->rep, TIPC_TLV_BEARER_NAME,
 			    nla_data(bearer[TIPC_NLA_BEARER_NAME]),
 			    nla_len(bearer[TIPC_NLA_BEARER_NAME]));
@@ -492,6 +495,9 @@ static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
 	if (err)
 		return err;
 
+	if (!link[TIPC_NLA_LINK_NAME])
+		return -EINVAL;
+
 	name = (char *)TLV_DATA(msg->req);
 	if (strcmp(name, nla_data(link[TIPC_NLA_LINK_NAME])) != 0)
 		return 0;
@@ -602,6 +608,9 @@ static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
 	if (err)
 		return err;
 
+	if (!link[TIPC_NLA_LINK_NAME])
+		return -EINVAL;
+
 	link_info.dest = nla_get_flag(link[TIPC_NLA_LINK_DEST]);
 	link_info.up = htonl(nla_get_flag(link[TIPC_NLA_LINK_UP]));
 	strcpy(link_info.str, nla_data(link[TIPC_NLA_LINK_NAME]));
@@ -981,6 +990,9 @@ static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
 	if (err)
 		return err;
 
+	if (!media[TIPC_NLA_MEDIA_NAME])
+		return -EINVAL;
+
 	return tipc_add_tlv(msg->rep, TIPC_TLV_MEDIA_NAME,
 			    nla_data(media[TIPC_NLA_MEDIA_NAME]),
 			    nla_len(media[TIPC_NLA_MEDIA_NAME]));
-- 
1.9.1
