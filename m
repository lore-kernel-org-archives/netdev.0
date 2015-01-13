From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: fix uninitialized variable warning
Date: Mon, 12 Jan 2015 16:25:28 -0800
Message-ID: <1421108728-12778-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:52138 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbAMAZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 19:25:35 -0500
Received: by mail-yh0-f44.google.com with SMTP id c41so34924yho.3
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 16:25:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roopa Prabhu <roopa@cumulusnetworks.com>

net/bridge/br_netlink.c: In function =E2=80=98br_fill_ifinfo=E2=80=99:
net/bridge/br_netlink.c:146:32: warning: =E2=80=98vid_range_flags=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
  err =3D br_fill_ifvlaninfo_range(skb, vid_range_start,
                                ^
net/bridge/br_netlink.c:108:6: note: =E2=80=98vid_range_flags=E2=80=99 =
was declared here
  u16 vid_range_flags;

Reported-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 0b03879..66ece91 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -105,7 +105,7 @@ static int br_fill_ifvlaninfo_compressed(struct sk_=
buff *skb,
 					 const struct net_port_vlans *pv)
 {
 	u16 vid_range_start =3D 0, vid_range_end =3D 0;
-	u16 vid_range_flags;
+	u16 vid_range_flags =3D 0;
 	u16 pvid, vid, flags;
 	int err =3D 0;
=20
@@ -142,12 +142,14 @@ initvars:
 		vid_range_flags =3D flags;
 	}
=20
-	/* Call it once more to send any left over vlans */
-	err =3D br_fill_ifvlaninfo_range(skb, vid_range_start,
-				       vid_range_end,
-				       vid_range_flags);
-	if (err)
-		return err;
+	if (vid_range_start !=3D 0) {
+		/* Call it once more to send any left over vlans */
+		err =3D br_fill_ifvlaninfo_range(skb, vid_range_start,
+					       vid_range_end,
+					       vid_range_flags);
+		if (err)
+			return err;
+	}
=20
 	return 0;
 }
--=20
1.7.10.4
