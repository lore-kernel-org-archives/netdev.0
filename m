From: fgao@ikuai8.com
Subject: [PATCH v3 net-next] l2tp: Refactor the codes with existing macros instead of literal number
Date: Sat, 20 Aug 2016 23:52:27 +0800
Message-ID: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: paulus@samba.org, davem@davemloft.net, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:48438 "EHLO smtpbg252.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753832AbcHTPxW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 11:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
0x03, and 2 separately.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v3: Modify the subject;
 v2: Only replace the literal number with macros according to Guillaume's advice
 v1: Inital patch

 net/l2tp/l2tp_ppp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d9560aa..65e2fd6 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -177,7 +177,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, 2))
 		return 1;
 
-	if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
+	if ((skb->data[0] == PPP_ALLSTATIONS) && (skb->data[1] == PPP_UI))
 		skb_pull(skb, 2);
 
 	return 0;
@@ -282,7 +282,7 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
 static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 			    size_t total_len)
 {
-	static const unsigned char ppph[2] = { 0xff, 0x03 };
+	static const unsigned char ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int error;
@@ -369,7 +369,7 @@ error:
  */
 static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
-	static const u8 ppph[2] = { 0xff, 0x03 };
+	static const u8 ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
 	struct l2tp_session *session;
@@ -440,7 +440,7 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
 	if (sock) {
-		inet_shutdown(sock, 2);
+		inet_shutdown(sock, SEND_SHUTDOWN);
 		/* Don't let the session go away before our socket does */
 		l2tp_session_inc_refcount(session);
 	}
-- 
1.9.1
