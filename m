From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/4] ax25: more common return path joining
Date: Sat,  7 Feb 2009 02:21:01 +0200
Message-ID: <1233966063-2419-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1233966063-2419-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Ralf Baechle <ralf@linux-mips.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47349 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZBGAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 19:21:07 -0500
In-Reply-To: <1233966063-2419-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 net/ax25/ax25_iface.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ax25/ax25_iface.c b/net/ax25/ax25_iface.c
index 8443af5..71338f1 100644
--- a/net/ax25/ax25_iface.c
+++ b/net/ax25/ax25_iface.c
@@ -61,27 +61,24 @@ void ax25_protocol_release(unsigned int pid)
=20
 	write_lock_bh(&protocol_list_lock);
 	protocol =3D protocol_list;
-	if (protocol =3D=3D NULL) {
-		write_unlock_bh(&protocol_list_lock);
-		return;
-	}
+	if (protocol =3D=3D NULL)
+		goto out;
=20
 	if (protocol->pid =3D=3D pid) {
 		protocol_list =3D protocol->next;
-		write_unlock_bh(&protocol_list_lock);
-		return;
+		goto out;
 	}
=20
 	while (protocol !=3D NULL && protocol->next !=3D NULL) {
 		if (protocol->next->pid =3D=3D pid) {
 			s =3D protocol->next;
 			protocol->next =3D protocol->next->next;
-			write_unlock_bh(&protocol_list_lock);
-			return;
+			goto out;
 		}
=20
 		protocol =3D protocol->next;
 	}
+out:
 	write_unlock_bh(&protocol_list_lock);
 }
=20
--=20
1.5.6.5

