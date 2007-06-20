From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 8/8] s390: netiucv inlining cleanup
Date: Wed, 20 Jun 2007 13:03:57 +0200
Message-ID: <20070620110357.GH9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47232 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbXFTLDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 07:03:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KB3iE8004288
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KB3icX507278
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KB3io6005064
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 07:03:44 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

The recent iucv rework patches re-introduced some unnecessary inlines.
Remove them again.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 drivers/s390/net/netiucv.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 5303aea..3d28e1a 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -134,18 +134,6 @@ PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
 		   *(((char*)ptr)+28),*(((char*)ptr)+29), \
 		   *(((char*)ptr)+30),*(((char*)ptr)+31));
 
-static inline void iucv_hex_dump(unsigned char *buf, size_t len)
-{
-	size_t i;
-
-	for (i = 0; i < len; i++) {
-		if (i && !(i % 16))
-			printk("\n");
-		printk("%02x ", *(buf + i));
-	}
-	printk("\n");
-}
-
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 static struct device_driver netiucv_driver = {
@@ -280,7 +268,7 @@ static u8 iucvMagic[16] = {
  *
  * @returns The printable string (static data!!)
  */
-static inline char *netiucv_printname(char *name)
+static char *netiucv_printname(char *name)
 {
 	static char tmp[9];
 	char *p = tmp;
@@ -1730,7 +1718,7 @@ static struct attribute_group netiucv_stat_attr_group = {
 	.attrs = netiucv_stat_attrs,
 };
 
-static inline int netiucv_add_files(struct device *dev)
+static int netiucv_add_files(struct device *dev)
 {
 	int ret;
 
@@ -1744,7 +1732,7 @@ static inline int netiucv_add_files(struct device *dev)
 	return ret;
 }
 
-static inline void netiucv_remove_files(struct device *dev)
+static void netiucv_remove_files(struct device *dev)
 {
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 	sysfs_remove_group(&dev->kobj, &netiucv_stat_attr_group);
-- 
1.5.2.1

