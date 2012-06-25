From: sjur.brandeland@stericsson.com
Subject: [net-next 04/11] caif-hsi: Removed dead code
Date: Mon, 25 Jun 2012 19:49:36 +0200
Message-ID: <1340646583-21059-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34031 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab2FYRt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:49:58 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807265lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:57 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Simplify logic and remove dead code.

Signed-off-by: Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 1520814..f81f61f 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -680,12 +680,11 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			if (desc_pld_len < 0)
 				goto out_of_sync;
=20
-			if (desc_pld_len > 0)
+			if (desc_pld_len > 0) {
 				rx_len =3D desc_pld_len;
-
-			if (desc_pld_len > 0 &&
-					(piggy_desc->header & CFHSI_PIGGY_DESC))
-				rx_len +=3D CFHSI_DESC_SZ;
+				if (piggy_desc->header & CFHSI_PIGGY_DESC)
+					rx_len +=3D CFHSI_DESC_SZ;
+			}
=20
 			/*
 			 * Copy needed information from the piggy-backed
@@ -695,8 +694,6 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 					CFHSI_DESC_SHORT_SZ);
 			/* Mark no embedded frame here */
 			piggy_desc->offset =3D 0;
-			if (desc_pld_len =3D=3D -EPROTO)
-				goto out_of_sync;
 		}
 	}
=20
--=20
1.7.5.4
