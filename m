From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: [patch] net/ps3: Fix wireless AP connect error handling
Date: Mon, 30 Mar 2009 11:04:36 -0700
Message-ID: <49D109B4.7020808@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>
To: <linville@tuxdriver.com>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:32497
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757676AbZC3SUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>

This patch fixes the bug that the driver tries to continue to
connect(associate) to AP even if gelic_wl_do_{wpa,wep}_setup() fails,

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
---
 drivers/net/ps3_gelic_wireless.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2101,6 +2101,9 @@ static int gelic_wl_associate_bss(struct
 	if (ret) {
 		pr_debug("%s: WEP/WPA setup failed %d\n", __func__,
 			 ret);
+		ret = -EPERM;
+		gelic_wl_send_iwap_event(wl, NULL);
+		goto out;
 	}
 
 	/* start association */



