From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 04/11] isdn/gigaset: drop debug check on isochronous write
Date: Tue,  6 Jul 2010 02:18:53 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-04.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_GIGASET_DEBUG set, every isochronous USB frame after
an erroneous one was checked for more errors. This produced only
noise messages in practice, so drop it.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 2dab531..0ded364 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -1188,24 +1188,6 @@ static void write_iso_tasklet(unsigned long data)
 					break;
 				}
 			}
-#ifdef CONFIG_GIGASET_DEBUG
-			/* check assumption on remaining frames */
-			for (; i < BAS_NUMFRAMES; i++) {
-				ifd = &urb->iso_frame_desc[i];
-				if (ifd->status != -EINPROGRESS
-				    || ifd->actual_length != 0) {
-					dev_warn(cs->dev,
-					     "isochronous write: frame %d: %s, "
-					     "%d of %d bytes sent\n",
-					     i, get_usb_statmsg(ifd->status),
-					     ifd->actual_length, ifd->length);
-					offset = (ifd->offset +
-						  ifd->actual_length)
-						 % BAS_OUTBUFSIZE;
-					break;
-				}
-			}
-#endif
 			break;
 		case -EPIPE:			/* stall - probably underrun */
 			dev_err(cs->dev, "isochronous write stalled\n");
-- 
1.6.5.3.298.g39add
