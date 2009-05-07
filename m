From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH net-next-2.6] Network Drop Monitor: Fix skb_kill_datagram
Date: Thu, 07 May 2009 21:25:54 +0000
Message-ID: <1241731554.6567.25.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:23562 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbZEGVZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:25:56 -0400
Received: by rv-out-0506.google.com with SMTP id f9so800922rvb.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 14:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ead2ceb0ec9f85cff19c43b5cdb2f8a054484431 ("Network Drop Monitor:
Adding kfree_skb_clean for non-drops and modifying end-of-line points
for skbs") established new conventions for identifying dropped packets.

Align skb_kill_datagram() with these conventions so that packets that
get dropped just before the copy to userspace are properly tracked.

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/core/datagram.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 22ea437..e2a36f0 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -260,7 +260,9 @@ int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 	}
 
-	skb_free_datagram(sk, skb);
+	kfree_skb(skb);
+	sk_mem_reclaim_partial(sk);
+
 	return err;
 }
 
-- 
1.5.4.3



