From: akpm@linux-foundation.org
Subject: [patch 2/6] hfc_usb: fix read buffer overflow
Date: Fri, 18 Sep 2009 12:53:02 -0700
Message-ID: <200909181953.n8IJr3YN026236@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38796 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752931AbZIRTxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:53:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Check whether index is within bounds before testing the element.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hisax/hfc_usb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/isdn/hisax/hfc_usb.c~hfc_usb-fix-read-buffer-overflow drivers/isdn/hisax/hfc_usb.c
--- a/drivers/isdn/hisax/hfc_usb.c~hfc_usb-fix-read-buffer-overflow
+++ a/drivers/isdn/hisax/hfc_usb.c
@@ -817,8 +817,8 @@ collect_rx_frame(usb_fifo * fifo, __u8 *
 	}
 	/* we have a complete hdlc packet */
 	if (finish) {
-		if ((!fifo->skbuff->data[fifo->skbuff->len - 1])
-		    && (fifo->skbuff->len > 3)) {
+		if (fifo->skbuff->len > 3 &&
+				!fifo->skbuff->data[fifo->skbuff->len - 1]) {
 
 			if (fifon == HFCUSB_D_RX) {
 				DBG(HFCUSB_DBG_DCHANNEL,
_
