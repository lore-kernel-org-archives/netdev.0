From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 2/2] [IrDA] Removed incorrect IRDA_ASSERT()
Date: Mon, 15 Jan 2007 11:15:42 +0200
Message-ID: <20070115091542.GB3532@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:36732 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932144AbXAOJWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 04:22:22 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With USB2.0 bulk out MTU can be 512 bytes, so checking it only for 64 bytes is
incorrect.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/irda-usb.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 8381c04..a66aacf 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1515,8 +1515,6 @@ static inline int irda_usb_parse_endpoints(struct irda_usb_cb *self, struct usb_
 
 	IRDA_DEBUG(0, "%s(), And our endpoints are : in=%02X, out=%02X (%d), int=%02X\n",
 		__FUNCTION__, self->bulk_in_ep, self->bulk_out_ep, self->bulk_out_mtu, self->bulk_int_ep);
-	/* Should be 8, 16, 32 or 64 bytes */
-	IRDA_ASSERT(self->bulk_out_mtu == 64, ;);
 
 	return((self->bulk_in_ep != 0) && (self->bulk_out_ep != 0));
 }
-- 
1.4.4.4

