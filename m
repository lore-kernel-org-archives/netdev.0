From: Tobias Brunner <tobias.brunner@strongswan.org>
Subject: [PATCH net-next-2.6] af_key: fix SADB_X_SPDDELETE response
Date: Fri, 10 Oct 2008 22:16:48 +0200
Message-ID: <48EFB830.6030006@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sidv0150.hsr.ch ([152.96.52.150]:43914 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760568AbYJJUuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 16:50:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When deleting an SPD entry using SADB_X_SPDDELETE, c.data.byid is not 
initialized to zero in pfkey_spddelete(). Thus, key_notify_policy() 
responds with a PF_KEY message of type SADB_X_SPDDELETE2 instead of 
SADB_X_SPDDELETE.

Signed-off-by: Tobias Brunner <tobias.brunner@strongswan.org>
---

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 362fe31..e55e044 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2341,6 +2341,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
+	c.data.byid = 0;
 	c.event = XFRM_MSG_DELPOLICY;
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 

