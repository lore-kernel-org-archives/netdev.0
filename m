From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec] af_key: initialize satype in key_notify_policy_flush()
Date: Mon, 18 Feb 2013 16:24:20 +0100
Message-ID: <1361201060-31732-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48657 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209Ab3BRPjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 10:39:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field was left uninitialized. Some user daemons perform check against this
field.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/key/af_key.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b426a6..f9bd41e 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2688,6 +2688,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	hdr->sadb_msg_pid = c->portid;
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_errno = (uint8_t) 0;
+	hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
 	pfkey_broadcast(skb_out, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 	return 0;
-- 
1.8.0.1
