From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: remove func xgmac_wait_until_free() as
 duplicate
Date: Mon, 08 May 2017 15:34:14 -0400 (EDT)
Message-ID: <20170508.153414.1871607886646871422.davem@davemloft.net>
References: <1494243078-17917-1-git-send-email-ardeleanalex@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@nxp.com
To: ardeleanalex@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754550AbdEHTeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:34:16 -0400
In-Reply-To: <1494243078-17917-1-git-send-email-ardeleanalex@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Ardelean <ardeleanalex@gmail.com>
Date: Mon,  8 May 2017 14:31:18 +0300

> Looking at xgmac_wait_until_done() and xgmac_wait_until_free()
> functions, they seem to have turned out completely identical.
> 
> Though, judging from the git history it seems they
> initially weren't.
> 
> Remove xgmac_wait_until_free() in favor of xgmac_wait_until_done().
> 
> Signed-off-by: Alexandru Ardelean <ardeleanalex@gmail.com>

This situation got created by the commit below, I wonder if it
is even correct.

Certainly the original author of this code intended the MDIO
_data_ rather than the _status_ register to be polled.

Otherwise, why in the world have two functions which are in
every other regard identical?

commit 26eee0210ad72a29eb4a70b34320bda266f91a0d
Author: Shaohui Xie <Shaohui.Xie@freescale.com>
Date:   Mon Mar 16 18:55:50 2015 +0800

    net/fsl: fix a bug in xgmac_mdio
    
    There is a bug in xgmac_wait_until_done() which mdio_stat should be used
    instead of mdio_data when checking if busy bit is cleared.
    
    Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 3a83bc2..5f691f2 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -79,7 +79,7 @@ static int xgmac_wait_until_done(struct device *dev,
 
 	/* Wait till the MDIO write is complete */
 	timeout = TIMEOUT;
-	while ((ioread32be(&regs->mdio_data) & MDIO_DATA_BSY) && timeout) {
+	while ((ioread32be(&regs->mdio_stat) & MDIO_STAT_BSY) && timeout) {
 		cpu_relax();
 		timeout--;
 	}
