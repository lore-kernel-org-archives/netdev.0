From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Optimized handling of zero length entries in length info
Date: Wed, 22 Nov 2006 00:06:19 +0000 (GMT)
Message-ID: <20061122000619.26BF07B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:50368 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1756870AbWKVAGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:06:13 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

There are a high number of split USB transactions, which contain
only one packet but have a length info field. This patch optimizes
this code by stopping parsing the length info structure if a zero
length field is encountered.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -593,6 +593,8 @@ static void handle_rx_packet(struct zd_u
 		unsigned int l, k, n;
 		for (i = 0, l = 0;; i++) {
 			k = le16_to_cpu(get_unaligned(&length_info->length[i]));
+			if (k == 0)
+				return;
 			n = l+k;
 			if (n > length)
 				return;
