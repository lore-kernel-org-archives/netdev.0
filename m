From: Constantin Baranov <baranov@mercdev.com>
Subject: [PATCH 1/2] niu: fix PHY template choice for 10G copper
Date: Tue, 17 Feb 2009 15:43:23 +0400
Message-ID: <20090217154323.580fcb2f.baranov@mercdev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.dewahost.net ([205.234.111.6]:48627 "EHLO
	titan.dewahost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbZBQLna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 06:43:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a typo in niu_determine_phy_disposition() which resulted in
phy_template_1g_copper being selected for 10G/copper configuration.

Signed-off-by: Constantin Baranov <baranov@mercdev.com>
---
While working on support of link speed setting I discovered this piece
of code which seemed pretty strange to me. I believe this to be just a
typo. With its current state the code for 10G/copper card initialization
will likely be broken by the second patch alone (as it changes the way
the 1G card is initialized), this is why I'm submitting these two
patches together. I was unable to find any 10G/copper Neptune cards
available for testing, so I'm asking for the help of the community.

Can anyone on the list confirm that the current driver works for
10G/copper? This would be much appreciated.

David, could you please clarify which is the correct way to initialize
10G/copper card? If I'm wrong, and 1G code must really work with 10G
cards, could you please describe which would be the best way to separate
1G and 10G branches in the xcvr_init_1g() and link_status_1g() routines?

 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0c0b752..15c9e5f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -2456,7 +2456,7 @@ static int niu_determine_phy_disposition(struct niu *np)
 
 		case NIU_FLAGS_10G:
 			/* 10G copper */
-			tp = &phy_template_1g_copper;
+			tp = &phy_template_10g_copper;
 			break;
 
 		case NIU_FLAGS_FIBER:
-- 
1.6.0.6

