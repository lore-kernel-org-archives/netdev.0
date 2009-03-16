From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: [PATCH] ipv6: fix display of local and remote sit endpoints
Date: Mon, 16 Mar 2009 14:47:24 +0100
Message-ID: <87d4ch4m1f.fsf_-_@nemi.mork.no>
References: <alpine.LSU.2.00.0903091400200.28029@fbirervta.pbzchgretzou.qr>
	<200903091414.15171.rjw@sisk.pl>
	<alpine.LSU.2.00.0903091545430.2331@fbirervta.pbzchgretzou.qr>
	<200903141934.38915.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41361 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477AbZCPOEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 10:04:14 -0400
In-Reply-To: <200903141934.38915.rjw@sisk.pl> (Rafael J. Wysocki's message of
	"Sat, 14 Mar 2009 19:34:38 +0100")
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: fix display of local and remote sit endpoints

This fixes the regressions cause by
commit 1326c3d5a4b792a2b15877feb7fb691f8945d203
(v2.6.28-rc6-461-g23a12b1) broke the display of local and remote
addresses of an SIT tunnel in iproute2.

nt->parms is used by ipip6_tunnel_init() and therefore need to be
initialized first.

Tracked as http://bugzilla.kernel.org/show_bug.cgi?id=3D12868

Reported-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d3467e5..5cee2bc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -188,9 +188,9 @@ static struct ip_tunnel * ipip6_tunnel_locate(struc=
t net *net,
 	}
=20
 	nt =3D netdev_priv(dev);
-	ipip6_tunnel_init(dev);
=20
 	nt->parms =3D *parms;
+	ipip6_tunnel_init(dev);
=20
 	if (parms->i_flags & SIT_ISATAP)
 		dev->priv_flags |=3D IFF_ISATAP;
--=20
1.5.6.5

