From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 10/15] netvsc: replace modulus with mask for alignment
Date: Wed,  3 May 2017 16:01:12 -0700
Message-ID: <20170503230117.20070-11-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32825 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbdECXBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:31 -0400
Received: by mail-pf0-f170.google.com with SMTP id q20so1773780pfg.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:31 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since packet alignment (pkt_align) is always a power of 2, it
is safe to replace expensive divide with shift.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d9bd1a2db4db..767ff20d659e 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -722,7 +722,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	int i;
 	u32 msg_size = 0;
 	u32 padding = 0;
-	u32 remain = packet->total_data_buflen % net_device->pkt_align;
+	u32 remain = packet->total_data_buflen & (net_device->pkt_align - 1);
 	u32 page_count = packet->cp_partial ? packet->rmsg_pgcnt :
 		packet->page_buf_cnt;
 
-- 
2.11.0
