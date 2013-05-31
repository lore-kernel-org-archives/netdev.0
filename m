From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next 1/6] net/core: __hw_addr_create_ex does not initialize sync_cnt
Date: Thu, 30 May 2013 17:55:39 -0700
Message-ID: <1369961744-21460-2-git-send-email-fubar@us.ibm.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:59677 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3EaA4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:56:03 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 18:56:01 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E1861C90041
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:56 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0tvbR274840
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0ttgc011955
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 21:55:56 -0300
In-Reply-To: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The sync_cnt field is not being initialized, which can result
in arbitrary values in the field.  Fixed by initializing it to zero.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com> 

---
 net/core/dev_addr_lists.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index c013f38..1f919d9 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -39,6 +39,7 @@ static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
 	ha->refcount = 1;
 	ha->global_use = global;
 	ha->synced = sync;
+	ha->sync_cnt = 0;
 	list_add_tail_rcu(&ha->list, &list->list);
 	list->count++;
 
-- 
1.8.1.4
