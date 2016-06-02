From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] rds: fix an infoleak in rds_inc_info_copy
Date: Thu,  2 Jun 2016 04:11:20 -0400
Message-ID: <1464855080-29671-1-git-send-email-kjlu@gatech.edu>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last field "flags" of object "minfo" is not initialized.
Copying this object out may leak kernel stack data.
Assign 0 to it to avoid leak.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/rds/recv.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rds/recv.c b/net/rds/recv.c
index c0be1ec..8413f6c 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -561,5 +561,7 @@ void rds_inc_info_copy(struct rds_incoming *inc,
 		minfo.fport = inc->i_hdr.h_dport;
 	}
 
+	minfo.flags = 0;
+
 	rds_info_copy(iter, &minfo, sizeof(minfo));
 }
-- 
2.7.4
