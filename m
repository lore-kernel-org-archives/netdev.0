From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net 1/1] Phonet: refuse to send bigger than MTU packets
Date: Fri, 14 Nov 2008 11:08:30 +0200
Message-ID: <1226653710-27642-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:39144 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbYKNJJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 04:09:06 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mAE98cvt006253
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 11:09:01 +0200
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index defeb7a..7ab30f6 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -144,8 +144,8 @@ static int pn_send(struct sk_buff *skb, struct net_=
device *dev,
 	struct phonethdr *ph;
 	int err;
=20
-	if (skb->len + 2 > 0xffff) {
-		/* Phonet length field would overflow */
+	if (skb->len + 2 > 0xffff /* Phonet length field limit */ ||
+	    skb->len + sizeof(struct phonethdr) > dev->mtu) {
 		err =3D -EMSGSIZE;
 		goto drop;
 	}
--=20
1.5.4.3

