From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] snmp: Remove duplicate OUTMCAST stat increment
Date: Mon, 16 Nov 2015 13:09:10 -0500
Message-ID: <1447697350-28652-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Claus Jensen <claus.jensen@microsemi.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38004 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbbKPSJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 13:09:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the OUTMCAST stat is double incremented, getting bumped once in the mcast code
itself, and again in the common ip output path.  Remove the mcast bump, as its
not needed

Validated by the reporter, with good results

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Claus Jensen <claus.jensen@microsemi.com>
CC: Claus Jensen <claus.jensen@microsemi.com>
CC: David Miller <davem@davemloft.net>
---
 net/ipv6/mcast.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 124338a..5ee56d0 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1651,7 +1651,6 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
 	} else {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 	}
@@ -2015,7 +2014,6 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, full_len);
 	} else
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
-- 
2.5.0
