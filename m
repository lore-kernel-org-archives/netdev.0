From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next 4/6] net/core: dev_mc_sync_multiple calls wrong helper
Date: Thu, 30 May 2013 17:55:42 -0700
Message-ID: <1369961744-21460-5-git-send-email-fubar@us.ibm.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:59816 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab3EaA4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:56:05 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 18:56:04 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AE1326E8054
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:57 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0u1Bk335686
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:56:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0tx0M012322
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 21:56:00 -0300
In-Reply-To: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The dev_mc_sync_multiple function is currently calling
__hw_addr_sync, and not __hw_addr_sync_multiple.  This will result in
addresses only being synced to the first device from the set.

	Corrected by calling the _multiple variant.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com> 

---
 net/core/dev_addr_lists.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 8e2c2ef..6cda4e2 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -801,7 +801,7 @@ int dev_mc_sync_multiple(struct net_device *to, struct net_device *from)
 		return -EINVAL;
 
 	netif_addr_lock_nested(to);
-	err = __hw_addr_sync(&to->mc, &from->mc, to->addr_len);
+	err = __hw_addr_sync_multiple(&to->mc, &from->mc, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
 	netif_addr_unlock(to);
-- 
1.8.1.4
