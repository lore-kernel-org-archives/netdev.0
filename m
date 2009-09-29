From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: fix mutex imbalance
Date: Tue, 29 Sep 2009 10:16:39 +0300
Message-ID: <1254208599-1274-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:59345 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362AbZI2HQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 03:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

port_mutex was unlocked twice.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 07aa9f0..aa5b5a9 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -407,7 +407,6 @@ int pn_sock_get_port(struct sock *sk, unsigned shor=
t sport)
 	return -EADDRINUSE;
=20
 found:
-	mutex_unlock(&port_mutex);
 	pn->sobject =3D pn_object(pn_addr(pn->sobject), sport);
 	return 0;
 }
--=20
1.6.0.4

