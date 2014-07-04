From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 10/10] net/hsr: Fix NULL pointer dereference on incomplete
 hsr_newlink() params.
Date: Fri, 4 Jul 2014 23:42:00 +0200
Message-ID: <53B71FA8.2030809@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51951 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbaGDVlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:41:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If none of the slave interfaces are specified, struct nlattr *data[] ma=
y
be NULL. Make sure to check for that.

While I'm at it, fix the horrible error messages displayed when only on=
e
of the slave interfaces isn't specified.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_netlink.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index fbdf53f..a2c7e4c 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -37,13 +37,17 @@ static int hsr_newlink(struct net *src_net, struct =
net_device *dev,
 	struct net_device *link[2];
 	unsigned char multicast_spec;
=20
+	if (!data) {
+		netdev_info(dev, "HSR: No slave devices specified\n");
+		return -EINVAL;
+	}
 	if (!data[IFLA_HSR_SLAVE1]) {
-		netdev_info(dev, "IFLA_HSR_SLAVE1 missing!\n");
+		netdev_info(dev, "HSR: Slave1 device not specified\n");
 		return -EINVAL;
 	}
 	link[0] =3D __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLA=
VE1]));
 	if (!data[IFLA_HSR_SLAVE2]) {
-		netdev_info(dev, "IFLA_HSR_SLAVE2 missing!\n");
+		netdev_info(dev, "HSR: Slave2 device not specified\n");
 		return -EINVAL;
 	}
 	link[1] =3D __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLA=
VE2]));
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
