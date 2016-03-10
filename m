From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/3] ax25: add link layer header validation function
Date: Wed,  9 Mar 2016 21:58:33 -0500
Message-ID: <1457578714-36125-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:33403 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934829AbcCJC6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:58:42 -0500
Received: by mail-qg0-f65.google.com with SMTP id y89so4402499qge.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:58:41 -0800 (PST)
In-Reply-To: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

As variable length protocol, AX25 fails link layer header validation
tests based on a minimum length. header_ops.validate allows protocols
to validate headers that are shorter than hard_header_len. Implement
this callback for AX25.

See also http://comments.gmane.org/gmane.linux.network/401064

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ax25/ax25_ip.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index b563a3f..2fa3be9 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -228,8 +228,23 @@ netdev_tx_t ax25_ip_xmit(struct sk_buff *skb)
 }
 #endif
 
+static bool ax25_validate_header(const char *header, unsigned int len)
+{
+	ax25_digi digi;
+
+	if (!len)
+		return false;
+
+	if (header[0])
+		return true;
+
+	return ax25_addr_parse(header + 1, len - 1, NULL, NULL, &digi, NULL,
+			       NULL);
+}
+
 const struct header_ops ax25_header_ops = {
 	.create = ax25_hard_header,
+	.validate = ax25_validate_header,
 };
 
 EXPORT_SYMBOL(ax25_header_ops);
-- 
2.7.0.rc3.207.g0ac5344
