From: akpm@linux-foundation.org
Subject: [patch 3/5] drivers/bluetooth/bpa10x.c: fix memleak
Date: Wed, 21 Nov 2007 15:03:57 -0800
Message-ID: <200711212303.lALN3vsX013723@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47853 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbXKUXEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:04:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>

This patch fixea a memleak spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/bpa10x.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/bluetooth/bpa10x.c~drivers-bluetooth-bpa10xc-fix-memleak drivers/bluetooth/bpa10x.c
--- a/drivers/bluetooth/bpa10x.c~drivers-bluetooth-bpa10xc-fix-memleak
+++ a/drivers/bluetooth/bpa10x.c
@@ -423,6 +423,7 @@ static int bpa10x_send_frame(struct sk_b
 		break;
 
 	default:
+		usb_free_urb(urb);
 		return -EILSEQ;
 	}
 
_
