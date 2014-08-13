From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 10/10] IB/core: Avoid leakage from kernel to user space
Date: Wed, 13 Aug 2014 14:39:11 +0300
Message-ID: <1407929951-16362-11-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:40128 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbaHMLj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:59 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so7242258wib.9
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:58 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear the reserved field of struct ib_uverbs_async_event_desc which copied to
user space.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/core/uverbs_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index 1280e78f199d..607b62ce434b 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -477,6 +477,7 @@ static void ib_uverbs_async_handler(struct ib_uverbs_file *file,
 
 	entry->desc.async.element    = element;
 	entry->desc.async.event_type = event;
+	entry->desc.async.reserved   = 0;
 	entry->counter               = counter;
 
 	list_add_tail(&entry->list, &file->async_file->event_list);
-- 
1.9.3
