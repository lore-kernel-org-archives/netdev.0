From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH v2 1/3] ethernet:ti:cpsw: fix phy identification with multiple slaves on fixed-phy
Date: Wed, 16 Dec 2015 23:02:09 -0500
Message-ID: <51520f9b588a4386bed12168d6b4ec3441bd635f.1450309613.git.drivshin@allworx.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com> <cover.1450309613.git.drivshin@allworx.com> <5661B765.3050504@iktek.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33723 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466AbbLQECo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 23:02:44 -0500
In-Reply-To: <cover.1450309613.git.drivshin@allworx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pascal Speck (Iktek) <kernel@iktek.de>
Date: Fri, 04 Dec 2015 16:55:17 +0100

When using more than one slave with ti cpsw and fixed phy the pd->phy_id
will be always zero, but slave_data->phy_id must be unique. pd->phy_id
means a "phy hardware id" whereas slave_data->phy_id means an "unique id",
so we should use pd->addr which has the same unique meaning.

Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link PHY")
Signed-off-by: Pascal Speck <kernel@iktek.de>
---
This was originally submitted by Pascal Speck on December 4, but was not
picked up by patchwork. I suspect that is because the patch was mangled by
the mailer. The only changes I made were to manually fix the patch whitespace
and wrapping, and add the Fixes: tag.

 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 48b92c9..e3b220d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2047,7 +2047,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 			if (!pd)
 				return -ENODEV;
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, pd->bus->id, pd->phy_id);
+				 PHY_ID_FMT, pd->bus->id, pd->addr);
 			goto no_phy_slave;
 		}
 		parp = of_get_property(slave_node, "phy_id", &lenp);
--
2.5.0
