From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 4/5] drivers/isdn/hardware/icon: fix sparse warning: cast
	truncates bits
Date: Thu, 26 Feb 2009 00:11:23 +0100
Message-ID: <20090225231111.5377.77854.stgit@localhost.localdomain>
References: <20090225230737.5377.31370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:49403 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763502AbZBYXLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 18:11:31 -0500
In-Reply-To: <20090225230737.5377.31370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:
  drivers/isdn/hardware/eicon/debug.c:1201:32: warning: cast truncates bits from constant value (1000 becomes 0)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/isdn/hardware/eicon/debug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/debug.c b/drivers/isdn/hardware/eicon/debug.c
index 84318ec..33ce89e 100644
--- a/drivers/isdn/hardware/eicon/debug.c
+++ b/drivers/isdn/hardware/eicon/debug.c
@@ -1198,7 +1198,7 @@ int SuperTraceASSIGN (void* AdapterHandle, byte* data) {
         pC->xbuffer[5] = (byte)(rx_dma_magic >>  8);
         pC->xbuffer[6] = (byte)(rx_dma_magic >> 16);
         pC->xbuffer[7] = (byte)(rx_dma_magic >> 24);
-        pC->xbuffer[8] = (byte)DIVA_MAX_MANAGEMENT_TRANSFER_SIZE;
+	pC->xbuffer[8] = (byte)(DIVA_MAX_MANAGEMENT_TRANSFER_SIZE & 0xFF);
         pC->xbuffer[9] = (byte)(DIVA_MAX_MANAGEMENT_TRANSFER_SIZE >> 8);
         pC->xbuffer[10] = 0;
 

