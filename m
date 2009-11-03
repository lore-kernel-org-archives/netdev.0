From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next] Phonet: remove tautologies
Date: Tue,  3 Nov 2009 10:41:28 +0200
Message-ID: <1257237688-19068-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47076 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbZKCIlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 03:41:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

These checks don't make sense anymore since rtnl_notify() cannot fail.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_netlink.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index d8f5d3f..609e509 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -53,8 +53,7 @@ void phonet_address_notify(int event, struct net_devi=
ce *dev, u8 addr)
 		    RTNLGRP_PHONET_IFADDR, NULL, GFP_KERNEL);
 	return;
 errout:
-	if (err < 0)
-		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
+	rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
 }
=20
 static const struct nla_policy ifa_phonet_policy[IFA_MAX+1] =3D {
@@ -212,8 +211,7 @@ void rtm_phonet_notify(int event, struct net_device=
 *dev, u8 dst)
 			  RTNLGRP_PHONET_ROUTE, NULL, GFP_KERNEL);
 	return;
 errout:
-	if (err < 0)
-		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_ROUTE, err);
+	rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_ROUTE, err);
 }
=20
 static const struct nla_policy rtm_phonet_policy[RTA_MAX+1] =3D {
--=20
1.6.3.3

