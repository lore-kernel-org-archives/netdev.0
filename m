From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH 3/6] gianfar: Fix build with CONFIG_PM=y
Date: Wed, 11 Nov 2009 09:57:07 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B95097A@zin33exm22.fsl.freescale.net>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
	<20091111001105.GC8817@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Loeliger <jdl@jdl.com>, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: "Anton Vorontsov" <avorontsov@ru.mvista.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091111001105.GC8817@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

 

>-----Original Message-----
>From: Anton Vorontsov [mailto:avorontsov@ru.mvista.com] 
>Sent: Wednesday, November 11, 2009 5:41 AM
>To: David Miller
>Cc: Fleming Andy-AFLEMING; Jon Loeliger; Kumar 
>Gopalpet-B05799; Lennert Buytenhek; Stephen Hemminger; 
>netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
>Subject: [PATCH 3/6] gianfar: Fix build with CONFIG_PM=y
>
>commit fba4ed030cfae7efdb6b79a57b0c5a9d72c9 ("gianfar: Add 
>Multiple Queue Support") introduced the following build failure:
>
>  CC      gianfar.o
>gianfar.c: In function 'gfar_restore':
>gianfar.c:1249: error: request for member 'napi' in something 
>not a structure or union
>
>This patch fixes the issue.
>
>Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>---
> drivers/net/gianfar.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c 
>index 79c28f5..a5b0038 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -1246,7 +1246,7 @@ static int gfar_restore(struct device *dev)
> 		phy_start(priv->phydev);
> 
> 	netif_device_attach(ndev);
>-	napi_enable(&priv->gfargrp.napi);
>+	enable_napi(priv);
> 
> 	return 0;
> }


I am extreemely sorry for introducing this error, I missed it while
porting my last set of patches.

Thanks for fixing it.


--

Thanks
Sandeep
