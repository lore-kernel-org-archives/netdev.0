From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in he_init_group()
Date: Sat, 29 Aug 2009 20:59:04 +0200
Message-ID: <4A997A78.9080309@gmail.com>
References: <4A9979CC.2090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:48248 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbZH2Sxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 14:53:36 -0400
Received: by ewy2 with SMTP id 2so2974905ewy.17
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 11:53:37 -0700 (PDT)
In-Reply-To: <4A9979CC.2090905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

he_dev->rbps_virt or he_dev->rbpl_virt allocation may fail.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
There was another in the same function.

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 2de6406..8af1d3e 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -795,6 +795,8 @@ he_init_group(struct he_dev *he_dev, int group)
 	}
 	memset(he_dev->rbps_base, 0, CONFIG_RBPS_SIZE * sizeof(struct he_rbp));
 	he_dev->rbps_virt = kmalloc(CONFIG_RBPS_SIZE * sizeof(struct he_virt), GFP_KERNEL);
+	if (he_dev->rbps_virt == NULL)
+		return -ENOMEM;
 
 	for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
 		dma_addr_t dma_handle;
@@ -838,6 +840,8 @@ he_init_group(struct he_dev *he_dev, int group)
 	}
 	memset(he_dev->rbpl_base, 0, CONFIG_RBPL_SIZE * sizeof(struct he_rbp));
 	he_dev->rbpl_virt = kmalloc(CONFIG_RBPL_SIZE * sizeof(struct he_virt), GFP_KERNEL);
+	if (he_dev->rbpl_virt == NULL)
+		return -ENOMEM;
 
 	for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
 		dma_addr_t dma_handle;
