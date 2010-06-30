From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ehea: Allocate stats buffer with GFP_KERNEL
Date: Wed, 30 Jun 2010 16:59:12 -0500
Message-ID: <201006302159.o5ULx8ow025348@d01av03.pok.ibm.com>
Cc: osstklei@de.ibm.com, raisch@de.ibm.com, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:59122 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562Ab0F3V7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 17:59:11 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5ULlA2v022404
	for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 17:47:10 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5ULx9br2183210
	for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 17:59:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5ULx99l025409
	for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 18:59:09 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since ehea_get_stats calls ehea_h_query_ehea_port, which
can sleep, we can also sleep when allocating a page in
this function. This fixes some memory allocation failure
warnings seen under low memory conditions.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ehea/ehea_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ehea/ehea_main.c~ehea_get_stats_gfp drivers/net/ehea/ehea_main.c
--- linux-2.6/drivers/net/ehea/ehea_main.c~ehea_get_stats_gfp	2010-06-28 09:46:51.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ehea/ehea_main.c	2010-06-28 09:46:51.000000000 -0500
@@ -335,7 +335,7 @@ static struct net_device_stats *ehea_get
 
 	memset(stats, 0, sizeof(*stats));
 
-	cb2 = (void *)get_zeroed_page(GFP_ATOMIC);
+	cb2 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb2) {
 		ehea_error("no mem for cb2");
 		goto out;
_
