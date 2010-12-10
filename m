From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 25/27] e1000e: static analysis tools complain of a possible null ptr p dereference
Date: Fri, 10 Dec 2010 02:06:23 -0800
Message-ID: <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:57543
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753680Ab0LJKGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:06:36 -0500
To: davem@davemloft.net
In-Reply-To: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Adding this default case resolves the issue.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 29b09113..72ce0ec 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1992,6 +1992,10 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 			p = (char *) adapter +
 					e1000_gstrings_stats[i].stat_offset;
 			break;
+		default:
+			data[i] = 0;
+			continue;
+			break;
 		}
 
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-- 
1.7.3.2

