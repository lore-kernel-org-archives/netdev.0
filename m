From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 01/17] Drivers: hv: vmbus: Use the standard format string to format GUIDs
Date: Tue, 24 Jul 2012 09:01:25 -0700
Message-ID: <1343145701-3691-1-git-send-email-kys@microsoft.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:40439
	"HELO p3plsmtps2ded03-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753674Ab2GXPqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 11:46:37 -0400
In-Reply-To: <1343145672-3641-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Format GUIDS as per MSFT standard. This makes interacting with MSFT
tool stack easier.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/hv/vmbus_drv.c |   38 ++------------------------------------
 1 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/drivers/hv/vmbus_drv.c b/drivers/hv/vmbus_drv.c
index 4748086..b76e8b3 100644
--- a/drivers/hv/vmbus_drv.c
+++ b/drivers/hv/vmbus_drv.c
@@ -146,43 +146,9 @@ static ssize_t vmbus_show_device_attr(struct device *dev,
 	get_channel_info(hv_dev, device_info);
 
 	if (!strcmp(dev_attr->attr.name, "class_id")) {
-		ret = sprintf(buf, "{%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			       "%02x%02x%02x%02x%02x%02x%02x%02x}\n",
-			       device_info->chn_type.b[3],
-			       device_info->chn_type.b[2],
-			       device_info->chn_type.b[1],
-			       device_info->chn_type.b[0],
-			       device_info->chn_type.b[5],
-			       device_info->chn_type.b[4],
-			       device_info->chn_type.b[7],
-			       device_info->chn_type.b[6],
-			       device_info->chn_type.b[8],
-			       device_info->chn_type.b[9],
-			       device_info->chn_type.b[10],
-			       device_info->chn_type.b[11],
-			       device_info->chn_type.b[12],
-			       device_info->chn_type.b[13],
-			       device_info->chn_type.b[14],
-			       device_info->chn_type.b[15]);
+		ret = sprintf(buf, "{%pUl}\n", device_info->chn_type.b);
 	} else if (!strcmp(dev_attr->attr.name, "device_id")) {
-		ret = sprintf(buf, "{%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-			       "%02x%02x%02x%02x%02x%02x%02x%02x}\n",
-			       device_info->chn_instance.b[3],
-			       device_info->chn_instance.b[2],
-			       device_info->chn_instance.b[1],
-			       device_info->chn_instance.b[0],
-			       device_info->chn_instance.b[5],
-			       device_info->chn_instance.b[4],
-			       device_info->chn_instance.b[7],
-			       device_info->chn_instance.b[6],
-			       device_info->chn_instance.b[8],
-			       device_info->chn_instance.b[9],
-			       device_info->chn_instance.b[10],
-			       device_info->chn_instance.b[11],
-			       device_info->chn_instance.b[12],
-			       device_info->chn_instance.b[13],
-			       device_info->chn_instance.b[14],
-			       device_info->chn_instance.b[15]);
+		ret = sprintf(buf, "{%pUl}\n", device_info->chn_instance.b);
 	} else if (!strcmp(dev_attr->attr.name, "modalias")) {
 		print_alias_name(hv_dev, alias_name);
 		ret = sprintf(buf, "vmbus:%s\n", alias_name);
-- 
1.7.4.1
