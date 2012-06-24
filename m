From: sjur.brandeland@stericsson.com
Subject: [net 2/3] caif-hsi: Bugfix - Piggyback'ed embedded CAIF frame lost
Date: Sun, 24 Jun 2012 23:01:37 +0200
Message-ID: <1340571698-17892-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Per Ellefsen <Per.Ellefsen@stericsson.com>,
	Per Ellefsen <per.ellefsen@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65158 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab2FXVBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 17:01:48 -0400
Received: by lbbgm6 with SMTP id gm6so5685479lbb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 14:01:46 -0700 (PDT)
In-Reply-To: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Per Ellefsen <Per.Ellefsen@stericsson.com>

When receiving a piggyback'ed descriptor containing an
embedded frame, but no payload, the embedded frame was
lost.

Signed-off-by: Per Ellefsen <per.ellefsen@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 1520814..1f52ff3 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -693,8 +693,6 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			 */
 			memcpy(rx_buf, (u8 *)piggy_desc,
 					CFHSI_DESC_SHORT_SZ);
-			/* Mark no embedded frame here */
-			piggy_desc->offset =3D 0;
 			if (desc_pld_len =3D=3D -EPROTO)
 				goto out_of_sync;
 		}
@@ -737,6 +735,8 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			/* Extract any payload in piggyback descriptor. */
 			if (cfhsi_rx_desc(piggy_desc, cfhsi) < 0)
 				goto out_of_sync;
+			/* Mark no embedded frame after extracting it */
+			piggy_desc->offset =3D 0;
 		}
 	}
=20
--=20
1.7.5.4
