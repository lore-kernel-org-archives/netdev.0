From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-2.6] Phonet: fix skb leak in pipe endpoint accept()
Date: Thu,  8 Jul 2010 09:56:53 +0300
Message-ID: <1278572213-6239-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:55276 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab0GHG6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 02:58:23 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o686tTwF029971
	for <netdev@vger.kernel.org>; Thu, 8 Jul 2010 01:58:22 -0500
Received: from localhost.localdomain (esdhcp037110.research.nokia.com [172.21.37.110])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id o686ukCL006964
	for <netdev@vger.kernel.org>; Thu, 8 Jul 2010 09:56:47 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 94d72e8..b2a3ae6 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -698,6 +698,7 @@ static struct sock *pep_sock_accept(struct sock *sk=
, int flags, int *errp)
 		newsk =3D NULL;
 		goto out;
 	}
+	kfree_skb(oskb);
=20
 	sock_hold(sk);
 	pep_sk(newsk)->listener =3D sk;
--=20
1.7.0.4

