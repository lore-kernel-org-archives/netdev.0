From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get
 and and get_phys_port_name
Date: Mon, 24 Jul 2017 21:21:44 -0700 (PDT)
Message-ID: <20170724.212144.2149933616576079754.davem@davemloft.net>
References: <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
        <201707251020.bDXHsX68%fengguang.wu@intel.com>
        <20170724210617.651cd495@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, kbuild-all@01.org,
        netdev@vger.kernel.org, sathya.perla@broadcom.com
To: kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdGYEVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 00:21:45 -0400
In-Reply-To: <20170724210617.651cd495@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>
Date: Mon, 24 Jul 2017 21:06:17 -0700

> On Tue, 25 Jul 2017 10:44:49 +0800, kbuild test robot wrote:
>>    drivers/net/ethernet/broadcom/bnxt/bnxt.c: In function 'bnxt_init_one':
>> >> drivers/net/ethernet/broadcom/bnxt/bnxt.c:7897:5: error: 'struct net_device' has no member named 'switchdev_ops'; did you mean 'netdev_ops'?  
>>      dev->switchdev_ops = &bnxt_switchdev_ops;
>>         ^~
> 
> Check out SWITCHDEV_SET_OPS() from commit d643a75ac2bc ("net: switchdev:
> add SET_SWITCHDEV_OPS helper").

This was easy enough so I just pushed out:

====================
>From bc88055ab72c0eaa080926c888628b77d2055513 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 24 Jul 2017 21:20:16 -0700
Subject: [PATCH] bnxt_en: Use SWITCHDEV_SET_OPS().

Suggested by Jakub Kicinski.

Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and and get_phys_port_name")
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 82cbe1804821..badbc3550338 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7894,7 +7894,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->netdev_ops = &bnxt_netdev_ops;
 	dev->watchdog_timeo = BNXT_TX_TIMEOUT;
 	dev->ethtool_ops = &bnxt_ethtool_ops;
-	dev->switchdev_ops = &bnxt_switchdev_ops;
+	SWITCHDEV_SET_OPS(dev, &bnxt_switchdev_ops);
 	pci_set_drvdata(pdev, dev);
 
 	rc = bnxt_alloc_hwrm_resources(bp);
-- 
2.13.3
