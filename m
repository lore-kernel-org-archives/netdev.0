From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH/RFC] [POWERPC] Add fixed-phy support for fs_enet
Date: Wed, 12 Dec 2007 17:45:27 +0100
Message-ID: <47601027.2080104@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Scott Wood <scottwood@freescale.com>
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759207AbXLLQpw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support to use the fixed-link property
of an ethernet node to fs_enet for the
CONFIG_PPC_CPM_NEW_BINDING case.

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---
 drivers/net/fs_enet/fs_enet-main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index f2a4d39..8220c70 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1174,8 +1174,15 @@ static int __devinit find_phy(struct device_node *np,
 	struct device_node *phynode, *mdionode;
 	struct resource res;
 	int ret = 0, len;
+	const u32 *data;
+
+	data  = of_get_property(np, "fixed-link", NULL);
+	if (data) {
+		snprintf(fpi->bus_id, 16, PHY_ID_FMT, 0, *data);
+		return 0;
+	}

-	const u32 *data = of_get_property(np, "phy-handle", &len);
+	data = of_get_property(np, "phy-handle", &len);
 	if (!data || len != 4)
 		return -EINVAL;

-- 
1.5.3.7

