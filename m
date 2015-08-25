From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1267/1290] net/rds/ib_recv.c:382:28: sparse:
 incorrect type in initializer (different base types)
Date: Tue, 25 Aug 2015 15:55:00 -0700 (PDT)
Message-ID: <20150825.155500.290194488854444995.davem@davemloft.net>
References: <201508260636.uzScUNFH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, kbuild-all@01.org,
	ajaykumar.hotchandani@oracle.com, ssantosh@kernel.org,
	netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbbHYWzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:55:01 -0400
In-Reply-To: <201508260636.uzScUNFH%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 26 Aug 2015 06:42:39 +0800

> sparse warnings: (new ones prefixed by >>)
> 
>>> net/rds/ib_recv.c:382:28: sparse: incorrect type in initializer (different base types)
>    net/rds/ib_recv.c:382:28:    expected int [signed] can_wait
>    net/rds/ib_recv.c:382:28:    got restricted gfp_t
>    net/rds/ib_recv.c:828:23: sparse: cast to restricted __le64

Fixed by:

====================
[PATCH] rds: Fix improper gfp_t usage.

>> net/rds/ib_recv.c:382:28: sparse: incorrect type in initializer (different base types)
   net/rds/ib_recv.c:382:28:    expected int [signed] can_wait
   net/rds/ib_recv.c:382:28:    got restricted gfp_t
   net/rds/ib_recv.c:828:23: sparse: cast to restricted __le64

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rds/ib_recv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 3afdcbd..ed9b41e 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -379,7 +379,7 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp)
 	struct ib_recv_wr *failed_wr;
 	unsigned int posted = 0;
 	int ret = 0;
-	int can_wait = gfp & __GFP_WAIT;
+	bool can_wait = !!(gfp & __GFP_WAIT);
 	u32 pos;
 
 	/* the goal here is to just make sure that someone, somewhere
-- 
2.1.0
