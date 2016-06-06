From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net v2] sfc: report supported link speeds on SFP connections
Date: Mon, 6 Jun 2016 17:29:30 +0100
Message-ID: <a354e801-dc3e-bae4-0dcb-f174df8b9161@solarflare.com>
References: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarod Wilson <jarod@redhat.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

7000-series SFC NICs connected with an SFP+ module currently fail to
report any supported link speeds.

Reported-by: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_port.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 7f295c4..2a9228a 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -189,11 +189,12 @@ static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
 
 	case MC_CMD_MEDIA_XFP:
 	case MC_CMD_MEDIA_SFP_PLUS:
-		result |= SUPPORTED_FIBRE;
-		break;
-
 	case MC_CMD_MEDIA_QSFP_PLUS:
 		result |= SUPPORTED_FIBRE;
+		if (cap & (1 << MC_CMD_PHY_CAP_1000FDX_LBN))
+			result |= SUPPORTED_1000baseT_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
+			result |= SUPPORTED_10000baseT_Full;
 		if (cap & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
 			result |= SUPPORTED_40000baseCR4_Full;
 		break;
-- 
2.5.5
