From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH v2 2/2] pegasus: fixes reported packet length
Date: Wed, 27 Apr 2016 10:35:25 +0300
Message-ID: <1461742525-2748-3-git-send-email-petkan@mip-labs.com>
References: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, a1291762@gmail.com,
	Petko Manolov <petkan@mip-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42426 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752657AbcD0Hfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 03:35:36 -0400
In-Reply-To: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to ADM851x docs the ethernet packet is appended with 4
bytes, not 8.  Fixing this to report (hopefully) the right amount
of data.

Signed-off-by: Petko Manolov <petkan@mip-labs.com>
---
 drivers/net/usb/pegasus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index f919e20..780c217 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -497,7 +497,7 @@ static void read_bulk_callback(struct urb *urb)
 		pkt_len = buf[count - 3] << 8;
 		pkt_len += buf[count - 4];
 		pkt_len &= 0xfff;
-		pkt_len -= 8;
+		pkt_len -= 4;
 	}
 
 	/*
-- 
2.8.0.rc3
