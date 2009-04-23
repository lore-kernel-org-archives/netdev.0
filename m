From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: [patch] net/ps3: Fix wireless AP connect error handling
Date: Thu, 23 Apr 2009 15:46:17 -0700
Message-ID: <49F0EFB9.20709@am.sony.com>
References: <49D109B4.7020808@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:30669 "EHLO
	SG2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbZDWWqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 18:46:25 -0400
In-Reply-To: <49D109B4.7020808@am.sony.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>

This patch fixes the bug that the driver tries to continue to
connect(associate) to AP even if gelic_wl_do_{wpa,wep}_setup() fails,

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
---
Hi John,

I didn't see this get merged in to 2.6.30 yet.  Could you let me know the status?

-Geoff

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




