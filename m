From: "Levin, Alexander" <alexander.levin@verizon.com>
Subject: [PATCH] net: thunderx: correct bound check in nic_config_loopback
Date: Sat, 30 Jul 2016 22:49:44 -0400
Message-ID: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Levin, Alexander" <alexander.levin@verizon.com>
To: "sgoutham@cavium.com" <sgoutham@cavium.com>,
	"rric@kernel.org" <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Off by one in nic_config_loopback would access an invalid arrat variable when
vf id == MAX_LMAC.

Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 16ed203..a70f50d 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -615,7 +615,7 @@ static int nic_config_loopback(struct nicpf *nic, struct set_loopback *lbk)
 {
 	int bgx_idx, lmac_idx;
 
-	if (lbk->vf_id > MAX_LMAC)
+	if (lbk->vf_id >= MAX_LMAC)
 		return -1;
 
 	bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lbk->vf_id]);
-- 
2.7.4
