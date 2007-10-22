From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/2] : remove header_ops bug in qeth driver
Date: Mon, 22 Oct 2007 16:16:14 +0200
Message-ID: <20071022142044.628766000@linux.vnet.ibm.com>
References: <20071022141613.957690000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, apw@shadowen.org,
	kamalesh@linux.vnet.ibm.com, kaber@trash.net,
	shemminger@linux-foundation.org
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:4006 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbXJVOUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 10:20:50 -0400
Content-Disposition: inline; filename=qeth.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Remove qeth bug caused by commit:
[NET]: Move hardware header operations out of netdevice.

This is the second part of the qeth header_ops patch, since
first patch sent 10/19 has been insufficient.
Nevertheless first patch is still valid and should be kept.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-uschi/include/linux/netdevice.h
===================================================================
--- linux-2.6-uschi.orig/include/linux/netdevice.h
+++ linux-2.6-uschi/include/linux/netdevice.h
@@ -834,7 +834,7 @@ static inline int dev_hard_header(struct
 				  const void *daddr, const void *saddr,
 				  unsigned len)
 {
-	if (!dev->header_ops)
+	if (!dev->header_ops || !dev->header_ops->create)
 		return 0;
 
 	return dev->header_ops->create(skb, dev, type, daddr, saddr, len);

-- 
