From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] net: fix potential infoleak in rds_inc_info_copy
Date: Wed,  1 Jun 2016 12:11:16 -0400
Message-ID: <1464797476-26596-1-git-send-email-kjlu@gatech.edu>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33882 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbcFAQLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
