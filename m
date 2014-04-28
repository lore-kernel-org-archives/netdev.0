From: George Cherian <george.cherian@ti.com>
Subject: [PATCH 3/6] drivers: net: cpsw: Enable CPTS for DRA7xx and AM4372
Date: Mon, 28 Apr 2014 09:40:22 +0530
Message-ID: <1398658225-25873-4-git-send-email-george.cherian@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <t-kristo@ti.com>,
	<mturquette@linaro.org>, <linux@arm.linux.org.uk>,
	<galak@codeaurora.org>, <ijc+devicetree@hellion.org.uk>,
	<mark.rutland@arm.com>, <pawel.moll@arm.com>, <robh+dt@kernel.org>,
	<tony@atomide.com>, <bcousson@baylibre.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable cpts hardware time stamping for Dra7xx and AM4372.
This enables PTPv2 for DRA7xx and AM4372.

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 36aa109..085ffb5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1398,7 +1398,8 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 	struct hwtstamp_config cfg;
 
 	if (priv->version != CPSW_VERSION_1 &&
-	    priv->version != CPSW_VERSION_2)
+	    priv->version != CPSW_VERSION_2 &&
+	    priv->version != CPSW_VERSION_3)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
@@ -1443,6 +1444,7 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 		cpsw_hwtstamp_v1(priv);
 		break;
 	case CPSW_VERSION_2:
+	case CPSW_VERSION_3:
 		cpsw_hwtstamp_v2(priv);
 		break;
 	default:
@@ -1459,7 +1461,8 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 	struct hwtstamp_config cfg;
 
 	if (priv->version != CPSW_VERSION_1 &&
-	    priv->version != CPSW_VERSION_2)
+	    priv->version != CPSW_VERSION_2 &&
+	    priv->version != CPSW_VERSION_3)
 		return -EOPNOTSUPP;
 
 	cfg.flags = 0;
-- 
1.8.3.1

