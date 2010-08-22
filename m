From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 6/6] be2net: fix to get RxQ IDs 0 and 1.
Date: Sun, 22 Aug 2010 14:58:04 +0530
Message-ID: <20100822092754.GA22346@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2601 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab0HVJ2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 05:28:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under certain configurations, it is possible to get RxQ IDs from
firmware which are not 0 and 1. This change ensures RxQ IDs 0 & 1
for the be2net network interfaces.

Signed-off-by: Somnath K<somnathk@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 949d9a1..f1b1454 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2137,7 +2137,8 @@ static int be_setup(struct be_adapter *adapter)
 	if (be_physfn(adapter)) {
 		cap_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS |
 				BE_IF_FLAGS_PROMISCUOUS |
-				BE_IF_FLAGS_PASS_L3L4_ERRORS;
+				BE_IF_FLAGS_PASS_L3L4_ERRORS |
+				BE_IF_FLAGS_RSS;
 		en_flags |= BE_IF_FLAGS_PASS_L3L4_ERRORS;
 	}
 
-- 
1.7.0.4

