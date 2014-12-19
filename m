From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 1/3] bluetooth: hidp_connection_add() unsafe use of l2cap_pi()
Date: Fri, 19 Dec 2014 06:20:57 +0000
Message-ID: <1418970059-32486-1-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141219061801.GU22149@ZenIV.linux.org.uk>
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58024 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbaLSGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 01:21:01 -0500
In-Reply-To: <20141219061801.GU22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

it's OK after we'd verified the sockets, but not before that.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/bluetooth/hidp/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index cc25d0b..07348e1 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -1314,13 +1314,14 @@ int hidp_connection_add(struct hidp_connadd_req *req,
 {
 	struct hidp_session *session;
 	struct l2cap_conn *conn;
-	struct l2cap_chan *chan = l2cap_pi(ctrl_sock->sk)->chan;
+	struct l2cap_chan *chan;
 	int ret;
 
 	ret = hidp_verify_sockets(ctrl_sock, intr_sock);
 	if (ret)
 		return ret;
 
+	chan = l2cap_pi(ctrl_sock->sk)->chan;
 	conn = NULL;
 	l2cap_chan_lock(chan);
 	if (chan->conn)
-- 
2.1.3
