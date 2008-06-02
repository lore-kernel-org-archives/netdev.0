From: Adrian Bunk <adrian.bunk@movial.fi>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 19:54:22 +0300
Message-ID: <20080602165422.GA22051@cs181133002.pp.htv.fi>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:47601 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbYFBQyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 12:54:44 -0400
Content-Disposition: inline
In-Reply-To: <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 11:25:14AM -0500, Kumar Gala wrote:
>
> On Jun 2, 2008, at 11:03 AM, Jeff Garzik wrote:
>
>> Kumar Gala wrote:
>>> The core portions of the phylib aren't capable of being used as
>>> a module.  This isn't really any different than something like i2c
>>> in that the bus driver and core need to be built into the kernel.
>>> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
>>> ---
>>> Jeff, please consider this for 2.6.26 as w/o it we get build issues
>>> if phylib is config'd as a module on ppc.
>>> drivers/net/phy/Kconfig |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>>> index 6eb2d31..ab04cc7 100644
>>> --- a/drivers/net/phy/Kconfig
>>> +++ b/drivers/net/phy/Kconfig
>>> @@ -3,7 +3,7 @@
>>> #
>>> menuconfig PHYLIB
>>> -	tristate "PHY Device support and infrastructure"
>>> +	bool "PHY Device support and infrastructure"
>>> 	depends on !S390
>>> 	depends on NET_ETHERNET
>>
>> What are the issues?
>>
>> The core _should_ be able to be built as a module.
>
> The core provides functions like phy_read/phy_write.  Andy has recently 
> introduced board level workaround/fixups.  The problem is these 
> workarounds tend to use phy_read/phy_write and the board/platform code is 
> not built as modules.
>
> So we get errors like:
>
> arch/powerpc/platforms/built-in.o: In function `mpc8568_mds_phy_fixups':
> /home/galak/git/master/powerpc/arch/powerpc/platforms/85xx/ 
> mpc85xx_mds.c:99: undefined reference to `phy_write'
>...

At first glance PHYLIB=n might also cause similar problems.

Please send me the failing .config and I'll cook up a fix.

> - k

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

