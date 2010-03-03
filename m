From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cpmac: use after free
Date: Wed, 03 Mar 2010 01:07:33 -0800 (PST)
Message-ID: <20100303.010733.98407421.davem@davemloft.net>
References: <20100303084610.GH5086@bicker>
	<20100303085957.GA2961@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org, florian@openwrt.org,
	ralf@linux-mips.org, weil@mail.berlios.de,
	kernel-janitors@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753871Ab0CCJHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 04:07:14 -0500
In-Reply-To: <20100303085957.GA2961@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 3 Mar 2010 09:59:58 +0100

> Wed, Mar 03, 2010 at 09:46:10AM CET, error27@gmail.com wrote:
>>The original code dereferenced "cpmac_mii" after calling 
>>"mdiobus_free(cpmac_mii);"
>>
>>Signed-off-by: Dan Carpenter <error27@gmail.com>
>>---
>>Found by a static checker and not tested.  Sorry.  :/
>>
>>diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
>>index b85c81f..9d48942 100644
>>--- a/drivers/net/cpmac.c
>>+++ b/drivers/net/cpmac.c
>>@@ -1290,8 +1290,8 @@ void __devexit cpmac_exit(void)
>> {
>> 	platform_driver_unregister(&cpmac_driver);
>> 	mdiobus_unregister(cpmac_mii);
>>-	mdiobus_free(cpmac_mii);
>> 	iounmap(cpmac_mii->priv);
>>+	mdiobus_free(cpmac_mii);
>> }
>> 
>> module_init(cpmac_init);
> 
> Looks good. Thanks.
> 
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied.
