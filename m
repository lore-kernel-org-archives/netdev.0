From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: [PATCH] net: stmmac: fix maxmtu assignment to be within valid range
Date: Thu,  5 Jan 2017 18:47:57 +0800
Message-ID: <1483613277-6005-1-git-send-email-hock.leong.kweh@intel.com>
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        lars.persson@axis.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

There is no checking valid value of maxmtu when getting it from devicetree.
This resolution added the checking condition to ensure the assignment is
made within a valid range.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 39eb7a6..683d59f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3319,7 +3319,8 @@ int stmmac_dvr_probe(struct device *device,
 		ndev->max_mtu = JUMBO_LEN;
 	else
 		ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
-	if (priv->plat->maxmtu < ndev->max_mtu)
+	if ((priv->plat->maxmtu < ndev->max_mtu) &&
+	    (priv->plat->maxmtu >= ndev->min_mtu))
 		ndev->max_mtu = priv->plat->maxmtu;
 
 	if (flow_ctrl)
-- 
1.7.9.5
