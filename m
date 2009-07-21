From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: dropped datagrams accounting
Date: Tue, 21 Jul 2009 14:57:58 +0300
Message-ID: <1248177479-12669-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:54682 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbZGULzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 07:55:46 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtAsh011401
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:35 +0300
Received: from localhost.localdomain (esdhcp03634.research.nokia.com [172.21.36.34])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtWcD014694
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:34 +0300
In-Reply-To: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

The per-socket drop count is visible via /proc/net/phonet.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/datagram.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index e087862..ef5c75c 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -159,8 +159,11 @@ out_nofree:
 static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	int err =3D sock_queue_rcv_skb(sk, skb);
-	if (err < 0)
+	if (err < 0) {
 		kfree_skb(skb);
+		if (err =3D=3D -ENOMEM)
+			atomic_inc(&sk->sk_drops);
+	}
 	return err ? NET_RX_DROP : NET_RX_SUCCESS;
 }
=20
--=20
1.6.0.4

