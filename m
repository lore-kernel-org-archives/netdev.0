From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] packet: make packet too small warning match condition
Date: Thu,  8 Jan 2015 11:29:18 -0500
Message-ID: <1420734558-30979-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, jkmalinen@gmail.com, dborkman@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:41033 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998AbbAHQ3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 11:29:44 -0500
Received: by mail-yk0-f178.google.com with SMTP id 20so1666080yks.9
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 08:29:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The expression in ll_header_truncated() tests less than or equal, but
the warning prints less than. Update the warning.

Reported-by: Jouni Malinen <jkmalinen@gmail.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6880f34..0f02668 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2102,7 +2102,7 @@ static bool ll_header_truncated(const struct net_device *dev, int len)
 {
 	/* net device doesn't like empty head */
 	if (unlikely(len <= dev->hard_header_len)) {
-		net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
+		net_warn_ratelimited("%s: packet size is too short (%d <= %d)\n",
 				     current->comm, len, dev->hard_header_len);
 		return true;
 	}
-- 
2.2.0.rc0.207.ga3a616c
