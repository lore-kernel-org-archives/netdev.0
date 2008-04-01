From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 2/2] SCTP: fix wrong debug counting of bind_bucket
Date: Tue, 01 Apr 2008 11:42:12 +0800
Message-ID: <47F1AF14.2040600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55730 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbYDADoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 23:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not count it if the allocation of the object
is failed.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d994d82..698b741 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5761,8 +5761,8 @@ static struct sctp_bind_bucket *sctp_bucket_create(
 	struct sctp_bind_bucket *pp;
 
 	pp = kmem_cache_alloc(sctp_bucket_cachep, GFP_ATOMIC);
-	SCTP_DBG_OBJCNT_INC(bind_bucket);
 	if (pp) {
+		SCTP_DBG_OBJCNT_INC(bind_bucket);
 		pp->port = snum;
 		pp->fastreuse = 0;
 		INIT_HLIST_HEAD(&pp->owner);
-- 
1.5.4.rc3

