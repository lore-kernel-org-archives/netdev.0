From: Jan Weitzel <J.Weitzel@phytec.de>
Subject: Antwort: [patch] net/ethernet: ks8851_mll: signedness bug in ks8851_probe()
Date: Fri, 17 Feb 2012 09:00:51 +0100
Message-ID: <OF305A41EA.D95E3D10-ONC12579A7.002BCB7F-C12579A7.002C05CA@phytec.de>
References: <20120217064433.GC3666@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Danny Kukawka <danny.kukawka@bisect.de>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Thomas Meyer <thomas@m3y3r.de>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.visioncatalog.de ([217.6.246.34]:60463 "EHLO
	root.phytec.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317Ab2BQIAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 03:00:53 -0500
In-Reply-To: <20120217064433.GC3666@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> schrieb am 17.02.2012 07:44:33:

> Von: Dan Carpenter <dan.carpenter@oracle.com>
> An: Jan Weitzel <j.weitzel@phytec.de>
> Kopie: Alexey Dobriyan <adobriyan@gmail.com>, "David S. Miller" 
> <davem@davemloft.net>, Paul Gortmaker 
> <paul.gortmaker@windriver.com>, Thomas Meyer <thomas@m3y3r.de>, 
> Danny Kukawka <danny.kukawka@bisect.de>, netdev@vger.kernel.org, 
> kernel-janitors@vger.kernel.org
> Datum: 17.02.2012 07:45
> Betreff: [patch] net/ethernet: ks8851_mll: signedness bug in 
ks8851_probe()
> 
> netdev->irq is unsigned, so it's never less than zero.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Tested-by: Jan Weitzel <j.weitzel@phytec.de>

> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/
> ethernet/micrel/ks8851_mll.c
> index 10d5798..b8104d9 100644
> --- a/drivers/net/ethernet/micrel/ks8851_mll.c
> +++ b/drivers/net/ethernet/micrel/ks8851_mll.c
> @@ -1544,7 +1544,7 @@ static int __devinit ks8851_probe(struct 
> platform_device *pdev)
> 
>     netdev->irq = platform_get_irq(pdev, 0);
> 
> -   if (netdev->irq < 0) {
> +   if ((int)netdev->irq < 0) {
>        err = netdev->irq;
>        goto err_get_irq;
>     }
