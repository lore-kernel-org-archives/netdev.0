From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: fix NULL-deref in WARN() in skb_gso_segment()
Date: Tue, 17 Jan 2012 21:00:40 +0100 (CET)
Message-ID: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50408 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028Ab2AQUAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 15:00:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug was introduced in commit c8f44affb7244f2ac3e703cab13d55ede27621bb.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

[against net tree]

diff --git a/net/core/dev.c b/net/core/dev.c
index f494675..634a70a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1961,6 +1961,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *s=
kb,
 	__skb_pull(skb, skb->mac_len);
=20
 	if (unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL)) {
+		static const netdev_features_t null_features =3D 0;
 		struct net_device *dev =3D skb->dev;
 		struct ethtool_drvinfo info =3D {};
=20
@@ -1968,8 +1969,8 @@ struct sk_buff *skb_gso_segment(struct sk_buff *s=
kb,
 			dev->ethtool_ops->get_drvinfo(dev, &info);
=20
 		WARN(1, "%s: caps=3D(%pNF, %pNF) len=3D%d data_len=3D%d ip_summed=3D=
%d\n",
-		     info.driver, dev ? &dev->features : NULL,
-		     skb->sk ? &skb->sk->sk_route_caps : NULL,
+		     info.driver, dev ? &dev->features : &null_features,
+		     skb->sk ? &skb->sk->sk_route_caps : &null_features,
 		     skb->len, skb->data_len, skb->ip_summed);
=20
 		if (skb_header_cloned(skb) &&
--=20
1.7.8.3
