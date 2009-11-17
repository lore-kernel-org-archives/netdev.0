From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next] Phonet: missing rcu_dereference()
Date: Tue, 17 Nov 2009 10:17:24 +0200
Message-ID: <1258445844-6079-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57760 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbZKQIRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 03:17:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Reported-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index ed65da2..526d027 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -44,7 +44,7 @@ static struct phonet_protocol *phonet_proto_get(int p=
rotocol)
 		return NULL;
=20
 	rcu_read_lock();
-	pp =3D proto_tab[protocol];
+	pp =3D rcu_dereference(proto_tab[protocol]);
 	if (pp && !try_module_get(pp->prot->owner))
 		pp =3D NULL;
 	rcu_read_unlock();
--=20
1.6.3.3

