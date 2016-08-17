From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 2/2] kaweth: fix oops upon failed memory allocation
Date: Wed, 17 Aug 2016 11:59:29 +0200
Message-ID: <1471427969-2355-2-git-send-email-oneukum@suse.com>
References: <1471427969-2355-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, stern@rowland.harvard.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52539 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbcHQKGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 06:06:22 -0400
In-Reply-To: <1471427969-2355-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just return an error upon failure.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/kaweth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 37bf715..3cd6906 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1049,6 +1049,8 @@ static int kaweth_probe(
 		/* Download the firmware */
 		dev_info(dev, "Downloading firmware...\n");
 		kaweth->firmware_buf = (__u8 *)__get_free_page(GFP_KERNEL);
+		if (!kaweth->firmware_buf)
+				return -ENOMEM;
 		if ((result = kaweth_download_firmware(kaweth,
 						      "kaweth/new_code.bin",
 						      100,
-- 
2.1.4
