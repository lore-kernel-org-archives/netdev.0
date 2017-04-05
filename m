From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: loop: Fix uninitialized pvid variable
Date: Wed,  5 Apr 2017 11:19:30 -0700
Message-ID: <20170405181931.8145-2-f.fainelli@gmail.com>
References: <20170405181931.8145-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, dan.carpenter@oracle.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32790 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932443AbdDESTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 14:19:43 -0400
Received: by mail-io0-f193.google.com with SMTP id f84so2145958ioj.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 11:19:43 -0700 (PDT)
In-Reply-To: <20170405181931.8145-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan's static analyzer reported the following:

	drivers/net/dsa/dsa_loop.c:181 dsa_loop_port_vlan_del()
	error: XXX uninitialized symbol 'pvid'.

we were missing the assignment of pvid to ps->vid, so add that.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index bc5acc15edbf..ee55a902fa66 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -164,7 +164,7 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 	struct dsa_loop_priv *ps = ds->priv;
 	struct mii_bus *bus = ps->bus;
 	struct dsa_loop_vlan *vl;
-	u16 vid, pvid;
+	u16 vid, pvid = ps->pvid;
 
 	dev_dbg(ds->dev, "%s\n", __func__);
 
-- 
2.9.3
