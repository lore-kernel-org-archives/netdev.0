From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] af_key: initialize satype in key_notify_policy_flush()
Date: Wed, 27 Mar 2013 08:41:06 +0100
Message-ID: <1364370068-20025-2-git-send-email-steffen.klassert@secunet.com>
References: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53929 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537Ab3C0HlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 03:41:25 -0400
In-Reply-To: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This field was left uninitialized. Some user daemons perform check against this
field.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9ef7985..d5a4a79 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2694,6 +2694,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	hdr->sadb_msg_pid = c->portid;
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_errno = (uint8_t) 0;
+	hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
 	pfkey_broadcast(skb_out, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 	return 0;
-- 
1.7.9.5
