From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 3/3] caif: Add BUG_ON if dev_info is missing in
 packet
Date: Mon, 11 Apr 2011 22:43:52 +0200
Message-ID: <1302554632-13638-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:46879 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab1DKUoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:44:39 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI00AC99LZVC00@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:23 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0082H9LXJMZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:23 +0200 (CEST)
In-reply-to: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfmuxl.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 2ca9806..6bb338d 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -188,7 +188,8 @@ static int cfmuxl_transmit(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	u8 linkid;
 	struct cflayer *dn;
 	struct caif_payload_info *info =3D cfpkt_info(pkt);
-	dn =3D get_dn(muxl, cfpkt_info(pkt)->dev_info);
+	BUG_ON(!info);
+	dn =3D get_dn(muxl, info->dev_info);
 	if (dn =3D=3D NULL) {
 		pr_warn("Send data on unknown phy ID =3D %d (0x%x)\n",
 			info->dev_info->id, info->dev_info->id);
--=20
1.7.0.4

