From: Dan Carpenter <error27@gmail.com>
Subject: [patch v2] bluetooth: handle l2cap_create_connless_pdu() errors
Date: Mon, 26 Apr 2010 13:36:27 +0200
Message-ID: <20100426113627.GS29093@bicker>
References: <20100422095201.GO29647@bicker> <20100422123347.GA5265@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrei Emeltchenko <andrei.emeltchenko@nokia.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Gustavo F. Padovan" <gustavo@padovan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34208 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab0DZLgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 07:36:36 -0400
Content-Disposition: inline
In-Reply-To: <20100422123347.GA5265@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2cap_create_connless_pdu() can sometimes return ERR_PTR(-ENOMEM) or
ERR_PTR(-EFAULT).

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
In v2 I wrote the patch on top of Gustavo Padovon's devel tree

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index a668ef4..b32682c 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1712,8 +1712,12 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 	/* Connectionless channel */
 	if (sk->sk_type == SOCK_DGRAM) {
 		skb = l2cap_create_connless_pdu(sk, msg, len);
-		l2cap_do_send(sk, skb);
-		err = len;
+		if (IS_ERR(skb)) {
+			err = PTR_ERR(skb);
+		} else {
+			l2cap_do_send(sk, skb);
+			err = len;
+		}
 		goto done;
 	}
 
