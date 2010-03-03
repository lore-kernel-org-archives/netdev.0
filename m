From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch] cpmac: use after free
Date: Wed, 3 Mar 2010 09:59:58 +0100
Message-ID: <20100303085957.GA2961@psychotron.lab.eng.brq.redhat.com>
References: <20100303084610.GH5086@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Stefan Weil <weil@mail.berlios.de>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240Ab0CCJAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 04:00:13 -0500
Content-Disposition: inline
In-Reply-To: <20100303084610.GH5086@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 03, 2010 at 09:46:10AM CET, error27@gmail.com wrote:
>The original code dereferenced "cpmac_mii" after calling 
>"mdiobus_free(cpmac_mii);"
>
>Signed-off-by: Dan Carpenter <error27@gmail.com>
>---
>Found by a static checker and not tested.  Sorry.  :/
>
>diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
>index b85c81f..9d48942 100644
>--- a/drivers/net/cpmac.c
>+++ b/drivers/net/cpmac.c
>@@ -1290,8 +1290,8 @@ void __devexit cpmac_exit(void)
> {
> 	platform_driver_unregister(&cpmac_driver);
> 	mdiobus_unregister(cpmac_mii);
>-	mdiobus_free(cpmac_mii);
> 	iounmap(cpmac_mii->priv);
>+	mdiobus_free(cpmac_mii);
> }
> 
> module_init(cpmac_init);

Looks good. Thanks.

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

