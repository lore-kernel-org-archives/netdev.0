From: David Miller <davem@davemloft.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
 compilation
Date: Mon, 03 Nov 2008 00:20:21 -0800 (PST)
Message-ID: <20081103.002021.124910044.davem@davemloft.net>
References: <20081103071720.GB18153@roarinelk.homelinux.net>
	<20081103.000438.62068550.davem@davemloft.net>
	<20081103081724.GE18445@roarinelk.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: mano@roarinelk.homelinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754595AbYKCIUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:20:46 -0500
In-Reply-To: <20081103081724.GE18445@roarinelk.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <mano@roarinelk.homelinux.net>
Date: Mon, 3 Nov 2008 09:17:24 +0100

> That throws another error:
> 
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2063: error: expected ',' or ';' before '__attribute__'
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2078: error: expected ',' or ';' before '__attribute__'

Sorry, does this new version below work better?

I wish I could build this on sparc64 :-)

commit 55c8eb6c8eaa5009eed1557b296da5d4ea9c369a
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Nov 3 00:04:24 2008 -0800

    SMC91x: Fix compilation on some platforms.
    
    This reverts 51ac3beffd4afaea4350526cf01fe74aaff25eff ('SMC91x: delete
    unused local variable "lp"') and adds __maybe_unused markers to these
    (potentially) unused variables.
    
    The issue is that in some configurations SMC_IO_SHIFT evaluates
    to '(lp->io_shift)', but in some others it's plain '0'.
    
    Based upon a build failure report from Manuel Lauss.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 6f9895d..fc80f25 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2060,6 +2060,7 @@ static int smc_request_attrib(struct platform_device *pdev,
 			      struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
+	struct smc_local *lp __maybe_unused = netdev_priv(ndev);
 
 	if (!res)
 		return 0;
@@ -2074,6 +2075,7 @@ static void smc_release_attrib(struct platform_device *pdev,
 			       struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
+	struct smc_local *lp __maybe_unused = netdev_priv(ndev);
 
 	if (res)
 		release_mem_region(res->start, ATTRIB_SIZE);
