From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] selftests: psock_tpacket: fix status check
Date: Thu, 25 Apr 2013 11:08:00 +0200
Message-ID: <1366880880-3207-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938Ab3DYJID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 05:08:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing like this for TP_STATUS_AVAILABLE clearly is a stupid bug
since it always returns true. Fix this by only checking for flags
where the kernel owns the packet and negate this result, since we
also could run into the non-zero status TP_STATUS_WRONG_FORMAT
and need to reclaim frames.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 This is only for net-next, since net does not contain networking
 selftests yet.

 tools/testing/selftests/net/psock_tpacket.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index a8d7ffa..c41b586 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -300,7 +300,7 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 
 static inline int __v1_tx_kernel_ready(struct tpacket_hdr *hdr)
 {
-	return ((hdr->tp_status & TP_STATUS_AVAILABLE) == TP_STATUS_AVAILABLE);
+	return !(hdr->tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING));
 }
 
 static inline void __v1_tx_user_ready(struct tpacket_hdr *hdr)
@@ -311,7 +311,7 @@ static inline void __v1_tx_user_ready(struct tpacket_hdr *hdr)
 
 static inline int __v2_tx_kernel_ready(struct tpacket2_hdr *hdr)
 {
-	return ((hdr->tp_status & TP_STATUS_AVAILABLE) == TP_STATUS_AVAILABLE);
+	return !(hdr->tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING));
 }
 
 static inline void __v2_tx_user_ready(struct tpacket2_hdr *hdr)
-- 
1.7.11.7
