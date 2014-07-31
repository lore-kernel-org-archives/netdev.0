From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] netlink: Use PAGE_ALIGNED macro
Date: Thu, 31 Jul 2014 12:17:08 +0200
Message-ID: <1406801828-4220-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:55849 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756384AbaGaKRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 06:17:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PAGE_ALIGNED(...) instead of IS_ALIGNED(..., PAGE_SIZE).

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1b38f7f..ce82722 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -374,7 +374,7 @@ static int netlink_set_ring(struct sock *sk, struct nl_mmap_req *req,
 
 		if ((int)req->nm_block_size <= 0)
 			return -EINVAL;
-		if (!IS_ALIGNED(req->nm_block_size, PAGE_SIZE))
+		if (!PAGE_ALIGNED(req->nm_block_size))
 			return -EINVAL;
 		if (req->nm_frame_size < NL_MMAP_HDRLEN)
 			return -EINVAL;
-- 
2.0.1
