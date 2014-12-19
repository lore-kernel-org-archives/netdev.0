From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 3/3] bnep: bnep_add_connection() should verify that it's dealing with l2cap socket
Date: Fri, 19 Dec 2014 06:20:59 +0000
Message-ID: <1418970059-32486-3-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141219061801.GU22149@ZenIV.linux.org.uk>
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58025 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbaLSGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 01:21:01 -0500
In-Reply-To: <20141219061801.GU22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

same story as cmtp

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/bluetooth/bnep/core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 85bcc21..ce82722d0 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -533,6 +533,9 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 
 	BT_DBG("");
 
+	if (!l2cap_is_socket(sock))
+		return -EBADFD;
+
 	baswap((void *) dst, &l2cap_pi(sock->sk)->chan->dst);
 	baswap((void *) src, &l2cap_pi(sock->sk)->chan->src);
 
-- 
2.1.3
