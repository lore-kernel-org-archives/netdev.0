From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 3/3] drivers: net: xgene: fix new firmware backward compatibility with older driver
Date: Fri, 27 Feb 2015 12:08:30 -0800
Message-ID: <1425067710-14879-4-git-send-email-isubramanian@apm.com>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:51791 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755163AbbB0UE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:04:28 -0500
Received: by paceu11 with SMTP id eu11so25165737pac.7
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:04:27 -0800 (PST)
In-Reply-To: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the backward compatibile of the older driver with the
newer firmware by making the binding unique so that the older driver won't
recognize the non-supported interfaces.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 4de62b2..635a83b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1025,6 +1025,8 @@ static int xgene_enet_remove(struct platform_device *pdev)
 #ifdef CONFIG_ACPI
 static const struct acpi_device_id xgene_enet_acpi_match[] = {
 	{ "APMC0D05", },
+	{ "APMC0D30", },
+	{ "APMC0D31", },
 	{ }
 };
 MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
@@ -1033,6 +1035,8 @@ MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
 #ifdef CONFIG_OF
 static struct of_device_id xgene_enet_of_match[] = {
 	{.compatible = "apm,xgene-enet",},
+	{.compatible = "apm,xgene1-sgenet",},
+	{.compatible = "apm,xgene1-xgenet",},
 	{},
 };
 
-- 
1.9.1
