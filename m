From: Angelo Dureghello <angelo70@gmail.com>
Subject: Fwd: micrel: ksz8051 badly detected as ksz8031
Date: Mon, 13 Oct 2014 21:34:44 +0200
Message-ID: <543C2954.5010609@gmail.com>
References: <543BB635.80608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:45722 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaJMTes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 15:34:48 -0400
Received: by mail-wi0-f170.google.com with SMTP id hi2so10016458wib.3
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 12:34:46 -0700 (PDT)
Received: from [192.168.0.2] (host155-25-dynamic.14-87-r.retail.telecomitalia.it. [87.14.25.155])
        by mx.google.com with ESMTPSA id k10sm17674123wjb.28.2014.10.13.12.34.45
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Oct 2014 12:34:45 -0700 (PDT)
In-Reply-To: <543BB635.80608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i confirm, moving from kernel 3.5.1 to  3.17.0 the network Micrel phy 
link is non
functional.

The non working detection of KSZ8051 (taken default, ksz8031, from mdio 
driver)
breaks the functionality.

But this is probably due to the fact i am not using DT population, but 
just using
a minimal DT just to boot (to avoidto change the bootloader setup that's 
already
into production).

What change from 3.5.1 and 3.17.0 is mainly that DT support has been added.

If i copy the old 3.5.1 micrel.c i can have the link, but network was 
not working
properly.

So i brute-fixed the issue into 3.17.0 with this small patchfor my need,
Imiss the complete understanding still for a proper fix.Hope you can 
elucidate.




diff -crB drivers/net/ethernet/ti/davinci_mdio.c 
../linux-3.17/drivers/net/ethernet/ti/davinci_mdio.c
*** drivers/net/ethernet/ti/davinci_mdio.c      2014-10-13 
21:02:25.522022750 +0200
--- ../linux-3.17/drivers/net/ethernet/ti/davinci_mdio.c 2014-10-05 
21:23:04.000000000 +0200
***************
*** 320,327 ****
   }
   #endif

- extern struct phy_driver *micrel_pdrv;
-
   static int davinci_mdio_probe(struct platform_device *pdev)
   {
         struct mdio_platform_data *pdata = dev_get_platdata(&pdev->dev);
--- 320,325 ----
***************
*** 397,408 ****
         for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
                 phy = data->bus->phy_map[addr];
                 if (phy) {
-                       /*
-                        * Angelo : micrel broken the link adding OF 
support.
-                        * waiting for the patch, i force the link to 
out phy.
-                        */
-                       phy->drv = micrel_pdrv;
-                       data->bus->phy_map[addr] = phy;
                         dev_info(dev, "phy[%d]: device %s, driver %s\n",
                                  phy->addr, dev_name(&phy->dev),
                                  phy->drv ? phy->drv->name : "unknown");
--- 395,400 ----

diff -crB drivers/net/phy/micrel.c ../linux-3.17/drivers/net/phy/micrel.c
*** drivers/net/phy/micrel.c    2014-10-13 21:00:03.273616086 +0200
--- ../linux-3.17/drivers/net/phy/micrel.c      2014-10-05 
21:23:04.000000000 +0200
***************
*** 640,650 ****
                 ARRAY_SIZE(ksphy_driver));
   }

- /*
-  * angelo, temporary patch
-  */
- struct phy_driver *micrel_pdrv = &ksphy_driver[5];
-
   module_init(ksphy_init);
   module_exit(ksphy_exit);



Regards, angelo
