From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: do not dump addresses from other namespaces
Date: Mon,  1 Dec 2008 14:37:20 +0200
Message-ID: <1228135041-22241-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200812011436.25064.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:51513 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbYLAMhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 07:37:40 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mB1CbLN5030295
	for <netdev@vger.kernel.org>; Mon, 1 Dec 2008 14:37:37 +0200
In-Reply-To: <200812011436.25064.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index b1770d6..242fe8f 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -123,6 +123,7 @@ nla_put_failure:
=20
 static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback=
 *cb)
 {
+	struct net *net =3D sock_net(skb->sk);
 	struct phonet_device *pnd;
 	int dev_idx =3D 0, dev_start_idx =3D cb->args[0];
 	int addr_idx =3D 0, addr_start_idx =3D cb->args[1];
@@ -131,6 +132,8 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
 	list_for_each_entry(pnd, &pndevs.list, list) {
 		u8 addr;
=20
+		if (!net_eq(dev_net(pnd->netdev), net))
+			continue;
 		if (dev_idx > dev_start_idx)
 			addr_start_idx =3D 0;
 		if (dev_idx++ < dev_start_idx)
--=20
1.5.4.3

