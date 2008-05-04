From: Gunnar Larisch <Gunnar.Larisch@gmx.de>
Subject: [PATCH] [NET]: 3c980-TX needs EXTRA_PREAMBLE
Date: Sun,  4 May 2008 23:22:11 +0200
Message-ID: <1209936131-11721-1-git-send-email-Gunnar.Larisch@gmx.de>
Cc: netdev@vger.kernel.org, Gunnar Larisch <Gunnar.Larisch@gmx.de>
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37077 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752976AbYEDVWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 17:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethernet card 3c980-TX needs a mdio_sync() to initialize the ethernet
properly. This is forced by adding an EXTRA_PREAMBLE to its drv_flags.

Without this, the driver did not reconnect after a link loss.

Signed-off-by: Gunnar Larisch <Gunnar.Larisch@gmx.de>
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
1.5.4.2

