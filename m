From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: hold socket before giving it to sk_deliver_skb()
Date: Thu, 15 Oct 2009 16:00:00 +0300
Message-ID: <1255611600-18534-1-git-send-email-remi@remlab.net>
References: <3a7a7527184221041233e9ade71e4bf1@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:46950 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541AbZJONAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 09:00:36 -0400
In-Reply-To: <3a7a7527184221041233e9ade71e4bf1@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 8c84190..0412beb 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -112,8 +112,10 @@ void pn_deliver_sock_broadcast(struct net *net, st=
ruct sk_buff *skb)
 			continue;
=20
 		clone =3D skb_clone(skb, GFP_ATOMIC);
-		if (clone)
+		if (clone) {
+			sock_hold(sknode);
 			sk_receive_skb(sknode, clone, 0);
+		}
 	}
 	spin_unlock(&pnsocks.lock);
 }
--=20
1.6.0.4

