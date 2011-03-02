From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] pfkey: fix warning
Date: Tue, 1 Mar 2011 22:39:13 -0800
Message-ID: <20110301223913.2caf53c3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59812 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab1CBGjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 01:39:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_NET_KEY_MIGRATE is not defined the arguments of
pfkey_migrate stub do not match causing warning.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/key/af_key.c	2011-03-01 22:32:30.608511083 -0800
+++ b/net/key/af_key.c	2011-03-01 22:33:55.703791987 -0800
@@ -2560,7 +2560,7 @@ static int pfkey_migrate(struct sock *sk
 }
 #else
 static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
-			 struct sadb_msg *hdr, void **ext_hdrs)
+			 const struct sadb_msg *hdr, void * const *ext_hdrs)
 {
 	return -ENOPROTOOPT;
 }
