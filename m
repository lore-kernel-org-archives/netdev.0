From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next-2.6 1/2] cxgb3: FIx VLAN over Jumbo frames
Date: Sat, 13 Feb 2010 11:44:30 -0800
Message-ID: <20100213194429.27297.99280.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The mac is expected to auto-inflate the Maximum Frame size for VLAN
tagged frames. It however does not work with jumbo frames.
Work around the bug adding 4 to the Maximum Frame for MTUs
greater than 1536.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/xgmac.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 0109ee4..0c08de5 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -353,6 +353,9 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	 * packet size register includes header, but not FCS.
 	 */
 	mtu += 14;
+	if (mtu > 1536)
+		mtu += 4;
+
 	if (mtu > MAX_FRAME_SIZE - 4)
 		return -EINVAL;
 	t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
