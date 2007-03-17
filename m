From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/3] [net-2.6] IrDA: Delay needed when uploading firmware chunks
Date: Sat, 17 Mar 2007 04:03:36 +0200
Message-ID: <20070317020336.GE3429@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	nigelw@elder-gods.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.mail-out.ovh.net ([213.186.42.179]:43976 "HELO
	26.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933647AbXCQCDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 22:03:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 42101001.sb firmwares, we need a 10 ms delay between firmware chunks
upload on irda-usb.

Patch from Nigel Williams <nigelw@elder-gods.net>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/irda-usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 340ee99..1d510bd 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1057,6 +1057,8 @@ static int stir421x_fw_upload(struct irda_usb_cb *self,
 
 		if (ret < 0)
 			break;
+
+		mdelay(10);
 	}
 
 	kfree(patch_block);
-- 
1.5.0.2

