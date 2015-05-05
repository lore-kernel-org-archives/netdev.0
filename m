From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Fix off-by-one in counters manipulation
Date: Tue,  5 May 2015 17:07:11 +0300
Message-ID: <1430834832-13559-2-git-send-email-ogerlitz@mellanox.com>
References: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:54734 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992989AbbEEOHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 10:07:47 -0400
In-Reply-To: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

This caused the en_stats_adder helper to accumulate a field which is
not related to the counter, fix that.

Fixes: a3333b35da16 ('net/mlx4_en: Moderate ethtool callback to show [..]')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 54f0e5a..0a56f01 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -139,7 +139,7 @@ static unsigned long en_stats_adder(__be64 *start, __be64 *next, int num)
 	int i;
 	int offset = next - start;
 
-	for (i = 0; i <= num; i++) {
+	for (i = 0; i < num; i++) {
 		ret += be64_to_cpu(*curr);
 		curr += offset;
 	}
-- 
1.7.1
