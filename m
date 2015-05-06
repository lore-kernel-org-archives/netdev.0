From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: send explicit not supported error in nl compat
Date: Wed, 6 May 2015 13:58:56 +0200
Message-ID: <1430913536-4206-3-git-send-email-richard.alpe@ericsson.com>
References: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:65386 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbEFMDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:03:31 -0400
In-Reply-To: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

The legacy netlink API treated EPERM (permission denied) as
"operation not supported".

Reported-by: Tomi Ollila <tomi.ollila@iki.fi>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/netlink_compat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 809aaf0..53e0fee 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1121,7 +1121,7 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	err = tipc_nl_compat_handle(&msg);
-	if (err == -EOPNOTSUPP)
+	if ((err == -EOPNOTSUPP) || (err == -EPERM))
 		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_SUPPORTED);
 	else if (err == -EINVAL)
 		msg.rep = tipc_get_err_tlv(TIPC_CFG_TLV_ERROR);
-- 
2.1.4
