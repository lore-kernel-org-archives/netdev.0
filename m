From: "Pascal Speck (Iktek)" <kernel@iktek.de>
Subject: [PATCH] ethernet:ti:cpsw: fix phy identification with multiple slaves
 on fixed-phy
Date: Fri, 04 Dec 2015 16:55:17 +0100
Message-ID: <5661B765.3050504@iktek.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 340.hostserv.eu ([82.220.37.15]:35984 "EHLO 340.hostserv.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbbLDPzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 10:55:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using more than one slave with ti cpsw and fixed phy the pd->phy_id 
will be always zero, but slave_data->phy_id must be unique.
pd->phy_id means a "phy hardware id" whereas slave_data->phy_id means an 
"unique id", so we should use pd->addr which has the same unique meaning.

Signed-off-by: Pascal Speck <kernel@iktek.de>

---

--- a/drivers/net/ethernet/ti/cpsw.c 2015-11-30 03:58:26.000000000 +0100
+++ b/drivers/net/ethernet/ti/cpsw.c      2015-12-04 16:42:02.075450234 
+0100
@@ -2047,7 +2047,7 @@ static int cpsw_probe_dt(struct cpsw_pri
                         if (!pd)
                                 return -ENODEV;
                         snprintf(slave_data->phy_id, 
sizeof(slave_data->phy_id),
-                                PHY_ID_FMT, pd->bus->id, pd->phy_id);
+                                PHY_ID_FMT, pd->bus->id, pd->addr);
                         goto no_phy_slave;
                 }
                 parp = of_get_property(slave_node, "phy_id", &lenp);
