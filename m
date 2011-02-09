From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: fix timer in get_curr_sync_buff
Date: Wed, 9 Feb 2011 02:21:59 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1102090214460.3494@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Tinggong Wang <wangtinggong@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50685 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756039Ab1BIASl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 19:18:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Tinggong Wang <wangtinggong@gmail.com>

 	Fix get_curr_sync_buff to keep buffer for 2 seconds
as intended, not just for the current jiffie. By this way
we will sync more connection structures with single packet.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 	Patch is against lvs-test-2.6 from 09-FEB-2011
but should apply cleanly to net-next.

--- lvs-test-2.6-7c9989a/net/netfilter/ipvs/ip_vs_sync.c	2011-02-07 13:40:00.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_sync.c	2011-02-09 01:59:46.771351460 +0200
@@ -374,8 +374,8 @@ get_curr_sync_buff(struct netns_ipvs *ip
  	struct ip_vs_sync_buff *sb;

  	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff && (time == 0 ||
-	    time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+	if (ipvs->sync_buff &&
+	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
  		sb = ipvs->sync_buff;
  		ipvs->sync_buff = NULL;
  	} else
