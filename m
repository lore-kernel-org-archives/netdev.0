From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 1/3] pktgen: should not turn off vlan when we disable svlan
Date: Thu, 15 May 2014 17:46:35 +0800
Message-ID: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
Cc: Francesco Fondelli <francesco.fondelli@gmail.com>,
	netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:49498 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaEOJq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:46:59 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so868824pab.20
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 02:46:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will turn off svlan when disable vlan, but should keep vlan on when disable
svlan. Also fix the doc typo.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/pktgen.txt | 2 +-
 net/core/pktgen.c                   | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0e30c78..672fa23 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -150,7 +150,7 @@ Examples:
  pgset "svlan_cfi 0"      set canonical format identifier 0-1 (default 0)
 
  pgset "vlan_id 9999"     > 4095 remove vlan and svlan tags
- pgset "svlan 9999"       > 4095 remove svlan tag
+ pgset "svlan_id 9999"    > 4095 remove svlan tag
 
 
  pgset "tos XX"           set former IPv4 TOS field (e.g. "tos 28" for AF11 no ECN, default 00)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0304f98..dcf367f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1627,11 +1627,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->nr_labels = 0;    /* turn off MPLS */
 			sprintf(pg_result, "OK: svlan_id=%u", pkt_dev->svlan_id);
 		} else {
-			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				pr_debug("VLAN/SVLAN turned off\n");
+				pr_debug("SVLAN turned off\n");
 		}
 		return count;
 	}
-- 
1.8.1.4
