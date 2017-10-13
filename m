From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: check ps->sock before running
 pppol2tp_session_ioctl()
Date: Fri, 13 Oct 2017 19:22:35 +0200
Message-ID: <520e39809f7ca7d8b38282e3a6bf0bbf93219541.1507915312.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:46982 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdJMRWj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 13:22:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pppol2tp_session_ioctl() is called by pppol2tp_tunnel_ioctl(),
the session may be unconnected. That is, it was created by
pppol2tp_session_create() and hasn't been connected with
pppol2tp_connect(). In this case, ps->sock is NULL, so we need to check
for this case in order to avoid dereferencing a NULL pointer.

Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index bc6e8bfc5be4..f50452b919d5 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -988,6 +988,9 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		 session->name, cmd, arg);
 
 	sk = ps->sock;
+	if (!sk)
+		return -EBADR;
+
 	sock_hold(sk);
 
 	switch (cmd) {
-- 
2.15.0.rc0
