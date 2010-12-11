From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 25/27] e1000e: static analysis tools complain of a possible null ptr p dereference
Date: Fri, 10 Dec 2010 22:20:38 -0800
Message-ID: <1292048440-22125-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:35634
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085Ab0LKGUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:20:47 -0500
To: davem@davemloft.net
In-Reply-To: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Adding this default case resolves the issue.

v2- Removed "break" in default case based on feedback

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 29b09113..a7bec0b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1992,6 +1992,9 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 			p = (char *) adapter +
 					e1000_gstrings_stats[i].stat_offset;
 			break;
+		default:
+			data[i] = 0;
+			continue;
 		}
 
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-- 
1.7.3.2

