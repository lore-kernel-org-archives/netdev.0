From: Tushar Gohad <tgohad@mvista.com>
Subject: type of sadb_x_kmprivate_reserved in pfkeyv2.h
Date: Wed, 14 Jun 2006 15:13:08 -0700
Message-ID: <449089F4.1090500@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060605070305040400060203"
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:14070 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S932387AbWFNWNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:13:09 -0400
Received: from [192.168.1.246] (net-test1.az.mvista.com [10.50.1.142])
	by hermes.mvista.com (Postfix) with ESMTP id AAC3B1B4E8
	for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 15:13:08 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060605070305040400060203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David and folks,

In include/linux/pfkeyv2.h, is the type 'u_int32_t' for 
sadb_x_kmprivate_reserved intentional or just an error while bringing in 
the PF_KEY IPsec extensions from KAME?

struct sadb_x_kmprivate {
        uint16_t        sadb_x_kmprivate_len;
        uint16_t        sadb_x_kmprivate_exttype;
        u_int32_t       sadb_x_kmprivate_reserved;    <====
} __attribute__((packed));

This is causing erroneous ipsec-tools builds. How does the 
__BIT_TYPES_DEFINED define work? Seems like u_int32_t does not get 
defined in include/linux/types.h when building a userland program such 
as ipsec-tools.

An easy fix is to change the type to uint32_t. Patch attached.

Thanks.
- Tushar


--------------060605070305040400060203
Content-Type: text/x-patch;
 name="common_fix_pfkeyv2_type.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="common_fix_pfkeyv2_type.patch"

Source: MontaVista Software, Inc.
MR: 19039
Type: Defect Fix
Disposition: needs submitting to kernel.org
Signed-off-by: Tushar Gohad <tgohad@mvista.com>
Description:
    When bringing over the PF_KEY extensions for IPsec from the
KAME stack, folks probably forgot to change this only variable
to be of type uint32_t. Or otherwise. This is the easiest and 
harmless fix.

Index: linux-p4/include/linux/pfkeyv2.h
===================================================================
--- linux-p4.orig/include/linux/pfkeyv2.h
+++ linux-p4/include/linux/pfkeyv2.h
@@ -159,7 +159,7 @@ struct sadb_spirange {
 struct sadb_x_kmprivate {
 	uint16_t	sadb_x_kmprivate_len;
 	uint16_t	sadb_x_kmprivate_exttype;
-	u_int32_t	sadb_x_kmprivate_reserved;
+	uint32_t	sadb_x_kmprivate_reserved;
 } __attribute__((packed));
 /* sizeof(struct sadb_x_kmprivate) == 8 */
 

--------------060605070305040400060203--
