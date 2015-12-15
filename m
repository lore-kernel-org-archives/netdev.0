From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: automatically enable stable privacy mode if stable_secret set
Date: Tue, 15 Dec 2015 22:59:12 +0100
Message-ID: <1450216752-18088-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48557 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933629AbbLOV7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 16:59:36 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3EDB520E19
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 16:59:35 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn reported that while we switch all interfaces to privacy stab=
le mode
when setting the secret, we don't set this mode for new interfaces. Thi=
s
does not make sense, so change this behaviour.

=46ixes: 622c81d57b392cc ("ipv6: generation of stable privacy addresses=
 for link-local and autoconf")
Reported-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a57d3d17a6204c..17f8e7ea133b49 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -350,6 +350,12 @@ static struct inet6_dev *ipv6_add_dev(struct net_d=
evice *dev)
 	setup_timer(&ndev->rs_timer, addrconf_rs_timer,
 		    (unsigned long)ndev);
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf)=
);
+
+	if (ndev->cnf.stable_secret.initialized)
+		ndev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+	else
+		ndev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_EUI64;
+
 	ndev->cnf.mtu6 =3D dev->mtu;
 	ndev->cnf.sysctl =3D NULL;
 	ndev->nd_parms =3D neigh_parms_alloc(dev, &nd_tbl);
--=20
2.5.0
