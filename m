From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: loop: Initialize err in dsa_loop_vlan_dump
Date: Wed,  5 Apr 2017 11:19:31 -0700
Message-ID: <20170405181931.8145-3-f.fainelli@gmail.com>
References: <20170405181931.8145-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, dan.carpenter@oracle.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34247 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932295AbdDESTp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 14:19:45 -0400
Received: by mail-it0-f67.google.com with SMTP id e75so2164337itd.1
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 11:19:39 -0700 (PDT)
In-Reply-To: <20170405181931.8145-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan's static checker reported the following:

	drivers/net/dsa/dsa_loop.c:223 dsa_loop_port_vlan_dump()
	error: uninitialized symbol 'err'.

which could happen if we do hit the continue statement for each iteration of
the loop. Initialize err to 0 here.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index ee55a902fa66..f0fc4de4fc9a 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -194,7 +194,7 @@ static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
 	struct mii_bus *bus = ps->bus;
 	struct dsa_loop_vlan *vl;
 	u16 vid, vid_start = 0;
-	int err;
+	int err = 0;
 
 	dev_dbg(ds->dev, "%s\n", __func__);
 
-- 
2.9.3
