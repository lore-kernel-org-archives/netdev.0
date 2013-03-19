From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 02:41:32 +0300
Message-ID: <201303200241.33137.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:54367 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933625Ab3CSWkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:40:18 -0400
Received: by mail-la0-f44.google.com with SMTP id eb20so1990263lab.3
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 15:40:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One must check the result of ioremap() -- in this case it prevents potential
kernel oops when initializing TSU registers further on...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: renesas/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ renesas/drivers/net/ethernet/renesas/sh_eth.c
@@ -2446,6 +2446,11 @@ static int sh_eth_drv_probe(struct platf
 		}
 		mdp->tsu_addr = ioremap(rtsu->start,
 					resource_size(rtsu));
+		if (mdp->tsu_addr == NULL) {
+			ret = -ENOMEM;
+			dev_err(&pdev->dev, "TSU ioremap failed.\n");
+			goto out_release;
+		}
 		mdp->port = devno % 2;
 		ndev->features = NETIF_F_HW_VLAN_FILTER;
 	}
