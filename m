From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 08/11] bt/rfcomm/tty: join error paths
Date: Sat, 13 Dec 2008 21:17:48 +0200
Message-ID: <12291958721148-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711089-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711225-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958713600-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958712305-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958712963-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195872202-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbYLMTR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:56 -0500
In-Reply-To: <1229195872202-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/rfcomm/tty.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 111c6c8..d030c69 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -298,18 +298,15 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *=
req, struct rfcomm_dlc *dlc)
 out:
 	write_unlock_bh(&rfcomm_dev_lock);
=20
-	if (err < 0) {
-		kfree(dev);
-		return err;
-	}
+	if (err < 0)
+		goto free;
=20
 	dev->tty_dev =3D tty_register_device(rfcomm_tty_driver, dev->id, NULL=
);
=20
 	if (IS_ERR(dev->tty_dev)) {
 		err =3D PTR_ERR(dev->tty_dev);
 		list_del(&dev->list);
-		kfree(dev);
-		return err;
+		goto free;
 	}
=20
 	dev_set_drvdata(dev->tty_dev, dev);
@@ -321,6 +318,10 @@ out:
 		BT_ERR("Failed to create channel attribute");
=20
 	return dev->id;
+
+free:
+	kfree(dev);
+	return err;
 }
=20
 static void rfcomm_dev_del(struct rfcomm_dev *dev)
--=20
1.5.2.2

