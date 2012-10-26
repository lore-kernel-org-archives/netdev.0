From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cdc_ncm: error path lock fix
Date: Fri, 26 Oct 2012 09:44:09 +0200
Message-ID: <1351237449-23643-3-git-send-email-bjorn@mork.no>
References: <1351237449-23643-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49734 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887Ab2JZHoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 03:44:54 -0400
In-Reply-To: <1351237449-23643-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes the sparse warning

 drivers/net/usb/cdc_ncm.c:836:9: warning: context imbalance in 'cdc_nc=
m_txpath_bh' - different lock contexts for basic block

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 682b17a..11370fe 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -842,6 +842,8 @@ static void cdc_ncm_txpath_bh(unsigned long param)
 		netif_tx_lock_bh(ctx->netdev);
 		usbnet_start_xmit(NULL, ctx->netdev);
 		netif_tx_unlock_bh(ctx->netdev);
+	} else {
+		spin_unlock_bh(&ctx->mtx);
 	}
 }
=20
--=20
1.7.10.4
