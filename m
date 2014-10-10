From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: Micrel KSZ8031 - phy link missing
Date: Fri, 10 Oct 2014 11:32:18 +0200
Message-ID: <5437A7A2.3020700@gmail.com>
References: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39955 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaJJJcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 05:32:21 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so1402714wiv.17
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 02:32:20 -0700 (PDT)
In-Reply-To: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Bruno,

many thanks,

i still have the issue after patching kernel 3.17.

static int ksz8021_config_init(struct phy_device *phydev)
{
         const u16 val = KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE;
         int rc;

         rc = kszphy_setup_led(phydev, 0x1f, 4);
         if (rc)
                 dev_err(&phydev->dev, "failed to set led mode\n");

         /*
          * signalled no-link to linux-net community, followed
          * see [PATCH] phy/micrel: KSZ8031RNL RMII clock 
reconfiguration bug
          */
         rc = ksz_config_flags(phydev);
         if (rc < 0)
                 return rc;
         rc = phy_write(phydev, MII_KSZPHY_OMSO, val);

         return rc < 0 ? rc : 0;
}


I am using RMII in my custom board, don't know if it makes any difference.

Scanning device for bad blocks
Bad block table written to 0x000007fe0000, version 0x01
Bad block table written to 0x000007fc0000, version 0x01
8 cmdlinepart partitions found on MTD device davinci_nand.0
Creating 8 MTD partitions on "davinci_nand.0":
0x000000000000-0x000000020000 : "u-boot-env"
0x000000020000-0x000000180000 : "u-boot"
0x000000180000-0x0000001a0000 : "bootparms"
0x0000001a0000-0x000000200000 : "factory-info"
EMAC: device MAC address: 00:08:e1:03:2a:c5
GPIO LEDs: old hardware revision detected
0x000000200000-0x000000600000 : "kernel"
0x000000600000-0x000000700000 : "config"
0x000000700000-0x000004300000 : "rootfs"
0x000004300000-0x000007f00000 : "update"
davinci_nand davinci_nand.0: controller rev. 2.5
davinci_mdio davinci_mdio.0: Runtime PM disabled, clock forced on.
davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
davinci_mdio davinci_mdio.0: detected phy mask fffffffc
libphy: davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[0]: device davinci_mdio-0:00, driver 
Micrel KSZ8031
davinci_mdio davinci_mdio.0: phy[1]: device davinci_mdio-0:01, driver 
Micrel KSZ8031
omap_rtc da830-rtc: rtc core: registered da830-rtc as rtc0

......

Starting LED service: done
Setting time zone...
UTC
Time zone set
Starting network...
davinci_mdio davinci_mdio.0: resetting idled controller
net eth0: attached PHY driver [Micrel KSZ8031] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)
udhcpc (v1.20.2) started
Sending discover...
Sending discover...
Sending discover...
No lease, failing
.....




Angelo





On 09/10/2014 17:05, Bruno Thomsen wrote:
> [PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
