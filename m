From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 2/3] cmtp: cmtp_add_connection() should verify that it's dealing with l2cap socket
Date: Fri, 19 Dec 2014 06:20:58 +0000
Message-ID: <1418970059-32486-2-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141219061801.GU22149@ZenIV.linux.org.uk>
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58023 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaLSGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 01:21:01 -0500
In-Reply-To: <20141219061801.GU22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

... rather than relying on ciptool(8) never passing it anything else.  Give
it e.g. an AF_UNIX connected socket (from socketpair(2)) and it'll oops,
trying to evaluate &l2cap_pi(sock->sk)->chan->dst...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/bluetooth/cmtp/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 67fe5e8..fd57db8 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -333,6 +333,8 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 	int i, err;
 
 	BT_DBG("");
+	if (!l2cap_is_socket(sock))
+		return -EBADFD;
 
 	session = kzalloc(sizeof(struct cmtp_session), GFP_KERNEL);
 	if (!session)
-- 
2.1.3
