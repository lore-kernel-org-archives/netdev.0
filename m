From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [XFRM] STATE: Fix flusing with hash mask.
Date: Thu, 31 Aug 2006 21:00:17 +0900
Message-ID: <200608312100.17307.nakam@linux-ipv6.org>
References: <44EECBB0.7070001@linux-ipv6.org> <20060825232819.66C6.NAKAM@linux-ipv6.org> <20060825.154717.38711346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:29161 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750988AbWHaMAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 08:00:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060825.154717.38711346.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is a minor fix about transformation state flushing
for net-2.6.19. Please apply it.

---
 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4341795..9f63edd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -384,7 +384,7 @@ void xfrm_state_flush(u8 proto)
 	int i;
 
 	spin_lock_bh(&xfrm_state_lock);
-	for (i = 0; i < xfrm_state_hmask; i++) {
+	for (i = 0; i <= xfrm_state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 restart:
-- 
1.4.2

