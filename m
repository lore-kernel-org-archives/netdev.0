From: Richard Laing <richard.laing@alliedtelesis.co.nz>
Subject: [PATCH 1/1] net/ipv6: Correct PIM6 mrt_lock handling
Date: Thu,  3 Sep 2015 13:52:31 +1200
Message-ID: <1441245151-11495-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Cc: jmorris@namei.org,
	Richard Laing <richard.laing@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:59033 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174AbbICBwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 21:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the IPv6 multicast routing code the mrt_lock was not being released
correctly in the MFC iterator, as a result adding or deleting a MIF would
cause a hang because the mrt_lock could not be acquired.

This fix is a copy of the code for the IPv4 case and ensures that the lock
is released correctly.

Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
---

 net/ipv6/ip6mr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 74ceb73..5f36266 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -550,7 +550,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 
 	if (it->cache == &mrt->mfc6_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == mrt->mfc6_cache_array)
+	else if (it->cache == &mrt->mfc6_cache_array[it->ct])
 		read_unlock(&mrt_lock);
 }
 
