From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 1/3] net: mvpp2: fix typo in the tcam setup
Date: Tue, 24 Oct 2017 11:41:26 +0200
Message-ID: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a typo in the mvpp2_prs_tcam_data_cmp() function, as
the shift value is inverted with the data.

Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8621e835f362..2b79b570f4e5 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -1539,7 +1539,7 @@ static bool mvpp2_prs_tcam_data_cmp(struct mvpp2_prs_entry *pe, int offs,
 	int off = MVPP2_PRS_TCAM_DATA_BYTE(offs);
 	u16 tcam_data;
 
-	tcam_data = (8 << pe->tcam.byte[off + 1]) | pe->tcam.byte[off];
+	tcam_data = (pe->tcam.byte[off + 1] << 8) | pe->tcam.byte[off];
 	if (tcam_data != data)
 		return false;
 	return true;
-- 
2.14.2
