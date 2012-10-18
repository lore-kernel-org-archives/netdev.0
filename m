From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if update failed
Date: Thu, 18 Oct 2012 22:40:55 +0200
Message-ID: <1350592867-25651-3-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60362 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932400Ab2JRUmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 16:42:46 -0400
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device refuses our updated value, then we must be prepared
to receive URBs as big as the device wants to send.  Set rx_max
to the device provided value on error.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..6a65662 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -251,8 +251,11 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 			kfree(dwNtbInMaxSize);
 		}
 size_err:
-		if (err < 0)
-			pr_debug("Setting NTB Input Size failed\n");
+		if (err < 0) {
+			/* failed, so attempt to use the device suggested size */
+			ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
+			pr_debug("Setting NTB Input Size failed, reverting to %u\n", ctx->r=
x_max);
+		}
 	}
=20
 	/* verify maximum size of transmitted NTB in bytes */
--=20
1.7.10.4
