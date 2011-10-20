From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 03/17] greth: Allow PHYs to override ->read_status
Date: Thu, 20 Oct 2011 17:00:10 -0400
Message-ID: <1319144425-15547-4-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of manually calling genphy_read_status(), the greth driver
should call phy_read_status() to allow the PHY driver to override the
read_status method with its own version.

NOTE: Completely untested. Needs somebody with hardware to try it out.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/greth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 52a3900..e7f268f 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1367,7 +1367,7 @@ static int greth_mdio_init(struct greth_private *greth)
 		timeout = jiffies + 6*HZ;
 		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
 		}
-		genphy_read_status(greth->phy);
+		phy_read_status(greth->phy);
 		greth_link_change(greth->netdev);
 	}
 
-- 
1.7.2.5
