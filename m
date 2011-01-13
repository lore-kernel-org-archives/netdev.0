From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 02/10] GRETH: added option to disable a device node from bootloader.
Date: Thu, 13 Jan 2011 09:25:27 +0100
Message-ID: <1294907135-24884-2-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932429Ab1AMJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:03 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 1c2dbdb..1b10186 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1383,6 +1383,12 @@ static int __devinit greth_of_probe(struct platform_device *ofdev, const struct
 	int err;
 	int tmp;
 	unsigned long timeout;
+	int *ampopts;
+
+	/* Skip device if used by another OS instance */
+	ampopts = (int *) of_get_property(ofdev->dev.of_node, "ampopts", NULL);
+	if (ampopts && (*ampopts == 0))
+		return -EIO;
 
 	dev = alloc_etherdev(sizeof(struct greth_private));
 
-- 
1.5.4

