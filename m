From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 5/5] qed: Add missing port-mode
Date: Sun, 19 Jun 2016 15:18:15 +0300
Message-ID: <1466338695-15538-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49987 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751752AbcFSMSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:42 -0400
In-Reply-To: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'MODULE_FIBER' value replaced several other FIBER values
in newer management firmware images, so existing code would
fail to properly reflect its mode.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  | 1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 9afc15f..e29ed5a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -3700,6 +3700,7 @@ struct public_port {
 #define MEDIA_DA_TWINAX         0x3
 #define MEDIA_BASE_T            0x4
 #define MEDIA_SFP_1G_FIBER      0x5
+#define MEDIA_MODULE_FIBER      0x6
 #define MEDIA_KR                0xf0
 #define MEDIA_NOT_PRESENT       0xff
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 61cc686..c7e01b3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1085,6 +1085,7 @@ static int qed_get_port_type(u32 media_type)
 	case MEDIA_SFPP_10G_FIBER:
 	case MEDIA_SFP_1G_FIBER:
 	case MEDIA_XFP_FIBER:
+	case MEDIA_MODULE_FIBER:
 	case MEDIA_KR:
 		port_type = PORT_FIBRE;
 		break;
-- 
1.9.3
