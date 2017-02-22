From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: [PATCH] fjes: Move fjes driver info message into fjes_acpi_add()
Date: Wed, 22 Feb 2017 15:40:49 -0500
Message-ID: <210dfe59-18a0-4678-0a63-6751f21f0eb5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36048 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934299AbdBVUkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 15:40:33 -0500
Received: by mail-qk0-f196.google.com with SMTP id r90so2115405qki.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 12:40:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fjes driver is used only by FUJITSU servers and almost of all
servers in the world never use it. But currently if ACPI PNP0C02
is defined in the ACPI table, the following message is always shown:

  "FUJITSU Extended Socket Network Device Driver - version 1.2
   - Copyright (c) 2015 FUJITSU LIMITED"

The message makes users confused because there is no reason that
the message is shown in other vendor servers.

To avoid the confusion, the patch moves the message into
fjes_acpi_add() so that it is shows only when fjes_acpi_add()
succeeded.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
  drivers/net/fjes/fjes_main.c | 6 +++---
  1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b77e4ecf..8e1329c 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -151,6 +151,9 @@ static int fjes_acpi_add(struct acpi_device *device)
  						   ARRAY_SIZE(fjes_resource));
  	device->driver_data = plat_dev;

+	pr_info("%s - version %s - %s\n",
+		fjes_driver_string, fjes_driver_version, fjes_copyright);
+
  	return 0;
  }

@@ -1481,9 +1484,6 @@ static int __init fjes_init_module(void)
  {
  	int result;

-	pr_info("%s - version %s - %s\n",
-		fjes_driver_string, fjes_driver_version, fjes_copyright);
-
  	fjes_dbg_init();

  	result = platform_driver_register(&fjes_driver);
-- 
1.8.3.1
