From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 1/3] net: ipconfig: Add device name to debug messages
Date: Fri, 29 Jul 2016 11:30:37 +0200
Message-ID: <1469784639-15705-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
 <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Chris Friesen <cfriesen@nortel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:32931 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbcG2JbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 05:31:16 -0400
In-Reply-To: <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies understanding what happens when there is more than one
device.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 net/ipv4/ipconfig.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 1d71c40eaaf3..369e4a004850 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -666,14 +666,14 @@ static const u8 ic_bootp_cookie[4] =3D { 99, 130,=
 83, 99 };
 #ifdef IPCONFIG_DHCP
=20
 static void __init
-ic_dhcp_init_options(u8 *options)
+ic_dhcp_init_options(u8 *options, struct ic_device *d)
 {
 	u8 mt =3D ((ic_servaddr =3D=3D NONE)
 		 ? DHCPDISCOVER : DHCPREQUEST);
 	u8 *e =3D options;
 	int len;
=20
-	pr_debug("DHCP: Sending message type %d\n", mt);
+	pr_debug("DHCP: Sending message type %d (%s)\n", mt, d->dev->name);
=20
 	memcpy(e, ic_bootp_cookie, 4);	/* RFC1048 Magic Cookie */
 	e +=3D 4;
@@ -857,7 +857,7 @@ static void __init ic_bootp_send_if(struct ic_devic=
e *d, unsigned long jiffies_d
 	/* add DHCP options or BOOTP extensions */
 #ifdef IPCONFIG_DHCP
 	if (ic_proto_enabled & IC_USE_DHCP)
-		ic_dhcp_init_options(b->exten);
+		ic_dhcp_init_options(b->exten, d);
 	else
 #endif
 		ic_bootp_init_ext(b->exten);
@@ -1033,8 +1033,8 @@ static int __init ic_bootp_recv(struct sk_buff *s=
kb, struct net_device *dev, str
 	/* Is it a reply to our BOOTP request? */
 	if (b->op !=3D BOOTP_REPLY ||
 	    b->xid !=3D d->xid) {
-		net_err_ratelimited("DHCP/BOOTP: Reply not for us, op[%x] xid[%x]\n"=
,
-				    b->op, b->xid);
+		net_err_ratelimited("DHCP/BOOTP: Reply not for us on %s, op[%x] xid[=
%x]\n",
+				    d->dev->name, b->op, b->xid);
 		goto drop_unlock;
 	}
=20
@@ -1075,7 +1075,7 @@ static int __init ic_bootp_recv(struct sk_buff *s=
kb, struct net_device *dev, str
 				}
 			}
=20
-			pr_debug("DHCP: Got message type %d\n", mt);
+			pr_debug("DHCP: Got message type %d (%s)\n", mt, d->dev->name);
=20
 			switch (mt) {
 			case DHCPOFFER:
--=20
2.8.1
