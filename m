From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH 1/2] 3c980-TX needs EXTRA_PREAMBLE
Date: Mon,  5 May 2008 14:01:28 +0200
Message-ID: <12099888891786-git-send-email-klassert@mathematik.tu-chemnitz.de>
Cc: netdev@vger.kernel.org, Gunnar Larisch <Gunnar.Larisch@gmx.de>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:54893 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664AbYEEM33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 08:29:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gunnar Larisch <Gunnar.Larisch@gmx.de>

The ethernet card 3c980-TX needs a mdio_sync() to initialize the ethernet
properly. This is forced by adding an EXTRA_PREAMBLE to its drv_flags.

Without this, the driver did not reconnect after a link loss.

Signed-off-by: Gunnar Larisch <Gunnar.Larisch@gmx.de>
Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 6f8e7d4..e93c378 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -319,7 +319,7 @@ static struct vortex_chip_info {
 	{"3c920B-EMB-WNM (ATI Radeon 9100 IGP)",
 	 PCI_USES_MASTER, IS_TORNADO|HAS_MII|HAS_HWCKSM, 128, },
 	{"3c980 Cyclone",
-	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
+	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 
 	{"3c980C Python-T",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
-- 
1.5.3

