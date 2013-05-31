From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH v2 net 1/6] net/core: __hw_addr_create_ex does not initialize sync_cnt
Date: Fri, 31 May 2013 14:57:26 -0700
Message-ID: <1370037451-29466-2-git-send-email-fubar@us.ibm.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60903 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab3EaV5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 17:57:51 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 17:57:51 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C69B6C90043
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:47 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLvmOn310018
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLvlo4025517
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:57:48 -0300
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The sync_cnt field is not being initialized, which can result
in arbitrary values in the field.  Fixed by initializing it to zero.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com> 

---
 net/core/dev_addr_lists.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
1.7.1
