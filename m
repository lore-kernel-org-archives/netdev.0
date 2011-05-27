From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH] caif: Fix compile warning in caif_serial.c
Date: Fri, 27 May 2011 10:09:15 +0200
Message-ID: <1306483755-3588-1-git-send-email-sjur.brandeland@stericsson.com>
References: <20110526143006.2d1ef9f7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-next@vger.kernel.org,
	balbi@ti.com, netdev@vger.kernel.org,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:61050 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758715Ab1E0IJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 04:09:31 -0400
In-Reply-To: <20110526143006.2d1ef9f7.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the compile warning introduced by the patch:
"tty: make receive_buf() return the amout of bytes received"

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Note: Fixes compile issue in linux-next (no issue in net-2.6).

 drivers/net/caif/caif_serial.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_ser=
ial.c
index 73c7e03..751ebbd 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -191,7 +191,7 @@ static unsigned int ldisc_receive(struct tty_struct=
 *tty,
 		dev_info(&ser->dev->dev,
 			"Bytes received before initial transmission -"
 			"bytes discarded.\n");
-		return;
+		return count;
 	}
=20
 	BUG_ON(ser->dev =3D=3D NULL);
@@ -199,7 +199,7 @@ static unsigned int ldisc_receive(struct tty_struct=
 *tty,
 	/* Get a suitable caif packet and copy in data. */
 	skb =3D netdev_alloc_skb(ser->dev, count+1);
 	if (skb =3D=3D NULL)
-		return;
+		return 0;
 	p =3D skb_put(skb, count);
 	memcpy(p, data, count);
=20
--=20
1.7.0.4

