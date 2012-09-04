From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] netrom: copy_datagram_iovec can fail
Date: Tue, 04 Sep 2012 15:13:18 +0100
Message-ID: <20120904141315.26374.38822.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:43089 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757065Ab2IDNzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 09:55:35 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q84ESGjV006966
	for <netdev@vger.kernel.org>; Tue, 4 Sep 2012 15:28:22 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Check for an error from this and if so bail properly.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/netrom/af_netrom.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 06592d8..1b9024e 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1169,7 +1169,12 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	er = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (er < 0) {
+		skb_free_datagram(sk, skb);
+		release_sock(sk);
+		return er;
+	}
 
 	if (sax != NULL) {
 		sax->sax25_family = AF_NETROM;
