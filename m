From: akpm@linux-foundation.org
Subject: [patch 3/7] drivers/bluetooth/bpa10x.c: fix memleak
Date: Mon, 04 Feb 2008 23:48:16 -0800
Message-ID: <200802050747.m157lv5j010452@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36348 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753788AbYBEHsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:48:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
