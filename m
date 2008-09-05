From: Hannes Hering <hannes.hering@gmx.de>
Subject: [PATCH 1/2] ehea: Fix DLPAR memory handling
Date: Fri, 5 Sep 2008 16:36:26 +0200
Message-ID: <200809051636.26545.hannes.hering@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:56096 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbYIEOhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 10:37:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ehea busmap must be allocated only once in the first of many calls of the
ehea_create_busmap_callback.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---

diff -Nurp -X dontdiff linux-2.6.27-rc5/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.27-rc5/drivers/net/ehea/ehea_qmr.c	2008-08-29 00:52:02.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-09-05 15:31:30.000000000 +0200
@@ -595,7 +595,8 @@ static int ehea_create_busmap_callback(u
 	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
 	mr_len = *(unsigned long *)arg;
 
-	ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+	if (!ehea_bmap)
+		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 	if (!ehea_bmap)
 		return -ENOMEM;
 
