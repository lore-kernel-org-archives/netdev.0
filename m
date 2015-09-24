From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RESEND v3 7/9] phy: fixed-phy: properly validate phy in
 fixed_phy_update_state()
Date: Thu, 24 Sep 2015 20:36:23 +0100
Message-ID: <E1ZfCJb-0004Rx-G8@rmk-PC.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Validate that the phy_device passed into fixed_phy_update_state() is a
fixed-phy device before walking the list of phys for a fixed phy at the
same address.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/fixed_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fb1299c6326e..e23bf5b90e17 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -220,7 +220,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp;
 
-	if (!phydev || !phydev->bus)
+	if (!phydev || phydev->bus != fmb->mii_bus)
 		return -EINVAL;
 
 	list_for_each_entry(fp, &fmb->phys, node) {
-- 
2.1.0
