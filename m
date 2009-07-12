From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atl1c: add missing parentheses
Date: Sun, 12 Jul 2009 23:40:34 +0200
Message-ID: <4A5A5852.4010901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:34101 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbZGLVjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:39:09 -0400
Received: by ewy26 with SMTP id 26so2186270ewy.37
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 14:39:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parentheses are required or the comparison occurs before the bitand.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
#include <stdio.h>
int main()
{
        printf("0 & 1 == 0: %u\n", 0 & 1 == 0);
        printf("1 & 1 == 0: %u\n", 1 & 1 == 0);
        printf("(0 & 1) == 0: %u\n", (0 & 1) == 0);
        printf("(1 & 1) == 0: %u\n", (1 & 1) == 0);
        return 0;
}

output:
0 & 1 == 0: 0
1 & 1 == 0: 0
(0 & 1) == 0: 1
(1 & 1) == 0: 0

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index e1658ef..2a1120a 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -188,14 +188,14 @@ struct atl1c_tpd_ext_desc {
 #define RRS_HDS_TYPE_DATA	2
 
 #define RRS_IS_NO_HDS_TYPE(flag) \
-	(((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK == 0)
+	((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK) == 0)
 
 #define RRS_IS_HDS_HEAD(flag) \
-	(((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK == \
+	((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK) == \
 			RRS_HDS_TYPE_HEAD)
 
 #define RRS_IS_HDS_DATA(flag) \
-	(((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK == \
+	((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TYPE_MASK) == \
 			RRS_HDS_TYPE_DATA)
 
 /* rrs word 3 bit 0:31 */
@@ -245,7 +245,7 @@ struct atl1c_tpd_ext_desc {
 #define RRS_PACKET_TYPE_802_3  	1
 #define RRS_PACKET_TYPE_ETH	0
 #define RRS_PACKET_IS_ETH(word) \
-	(((word) >> RRS_PACKET_TYPE_SHIFT) & RRS_PACKET_TYPE_MASK == \
+	((((word) >> RRS_PACKET_TYPE_SHIFT) & RRS_PACKET_TYPE_MASK) == \
 			RRS_PACKET_TYPE_ETH)
 #define RRS_RXD_IS_VALID(word) \
 	((((word) >> RRS_RXD_UPDATED_SHIFT) & RRS_RXD_UPDATED_MASK) == 1)
