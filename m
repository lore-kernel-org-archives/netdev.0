From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vxlan: fix unused variable warning
Date: Wed, 14 Dec 2016 12:43:55 -0800
Message-ID: <20161214124355.7da92ff3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [74.125.83.50] ([74.125.83.50]:36348 "EHLO
        mail-pg0-f50.google.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752366AbcLNUpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 15:45:55 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so11575695pgc.3
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 12:45:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes commit 4528520d315ac1 ("vxlan: add ipv6 proxy support")
which added code that caused this warning:

drivers/net/vxlan.c: In function =E2=80=98neigh_reduce=E2=80=99:
drivers/net/vxlan.c:1556:25: warning: variable =E2=80=98saddr=E2=80=99 set =
but not used

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/vxlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bb70dd5..4147fd6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1553,7 +1553,7 @@ static int neigh_reduce(struct net_device *dev, struc=
t sk_buff *skb)
 	struct vxlan_dev *vxlan =3D netdev_priv(dev);
 	struct nd_msg *msg;
 	const struct ipv6hdr *iphdr;
-	const struct in6_addr *saddr, *daddr;
+	const struct in6_addr *daddr;
 	struct neighbour *n;
 	struct inet6_dev *in6_dev;
=20
@@ -1562,7 +1562,6 @@ static int neigh_reduce(struct net_device *dev, struc=
t sk_buff *skb)
 		goto out;
=20
 	iphdr =3D ipv6_hdr(skb);
-	saddr =3D &iphdr->saddr;
 	daddr =3D &iphdr->daddr;
=20
 	msg =3D (struct nd_msg *)skb_transport_header(skb);
--=20
2.10.2
