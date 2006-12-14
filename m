From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 3/6] d80211: fix classify_1d() priority selection
Date: Thu, 14 Dec 2006 12:02:27 +0800
Message-ID: <20061214040227.GA10661@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47167 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbWLNEOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:14:22 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't see any reason why packets with DSCP=0x40 should have lower IEEE
802.1D priority than packets with DSCP=0x20. Spare > Background. No?

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/d80211/wme.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

e1765ea0d80ad86619300d3253e801883fd745a5
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index b9505dc..f26fe6c 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -131,9 +131,9 @@ static inline unsigned classify_1d(struc
 	dscp = ip->tos & 0xfc;
 	switch (dscp) {
 	case 0x20:
-		return 2;
-	case 0x40:
 		return 1;
+	case 0x40:
+		return 2;
 	case 0x60:
 		return 3;
 	case 0x80:
-- 
1.2.6
