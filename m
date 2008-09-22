From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 05/10] ehea: fix DLPAR memory handling
Date: Mon, 22 Sep 2008 14:10:19 -0700
Message-ID: <200809222110.m8MLAJJ8029885@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	hannes.hering@gmx.de, hering2@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49146 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753277AbYIVVQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:16:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Hering <hannes.hering@gmx.de>

The ehea busmap must be allocated only once in the first of many calls of the
ehea_create_busmap_callback.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_qmr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/ehea/ehea_qmr.c~ehea-fix-dlpar-memory-handling drivers/net/ehea/ehea_qmr.c
--- a/drivers/net/ehea/ehea_qmr.c~ehea-fix-dlpar-memory-handling
+++ a/drivers/net/ehea/ehea_qmr.c
@@ -595,7 +595,8 @@ static int ehea_create_busmap_callback(u
 	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
 	mr_len = *(unsigned long *)arg;
 
-	ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+	if (!ehea_bmap)
+		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 	if (!ehea_bmap)
 		return -ENOMEM;
 
_
