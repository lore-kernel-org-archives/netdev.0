From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 5/5] bcma: invalidate the mapped window over suspend/resume
Date: Fri, 13 Jan 2012 00:02:53 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201130002080.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34834 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab2AMICS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:02:18 -0500
Received: by iabz25 with SMTP id z25so3987027iab.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 00:02:17 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=46rom: Rafa=B3 Mi=B3ecki <zajec5@gmail.com>
Date: Thu, 12 Jan 2012 23:51:30 -0800

This clears the current mapped window when suspending, so that the
resumed state will re-map them as required.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/bcma/main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index febbc0a1222a..d185039690bc 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -253,6 +253,8 @@ int bcma_bus_suspend(struct bcma_bus *bus)
 				adrv->suspend(core);
 		}
 	}
+
+	bus->mapped_core =3D NULL;
 	return 0;
 }
=20
--=20
1.7.8.rc2.3.g0911
