From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 02 Jun 2008 12:39:21 -0400
Message-ID: <48442239.7090906@garzik.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40696 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626AbYFBQjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 12:39:23 -0400
In-Reply-To: <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
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
>>> -    tristate "PHY Device support and infrastructure"
>>> +    bool "PHY Device support and infrastructure"
>>>     depends on !S390
>>>     depends on NET_ETHERNET
>>
>> What are the issues?
>>
>> The core _should_ be able to be built as a module.
> 
> The core provides functions like phy_read/phy_write.  Andy has recently 
> introduced board level workaround/fixups.  The problem is these 
> workarounds tend to use phy_read/phy_write and the board/platform code 
> is not built as modules.
> 
> So we get errors like:
> 
> arch/powerpc/platforms/built-in.o: In function `mpc8568_mds_phy_fixups':
> /home/galak/git/master/powerpc/arch/powerpc/platforms/85xx/mpc85xx_mds.c:99: 
> undefined reference to `phy_write'
> /home/galak/git/master/powerpc/arch/powerpc/platforms/85xx/mpc85xx_mds.c:104: 
> undefined reference to `phy_read'

The whole world isn't embedded ppc, we use this stuff elsewhere too.

You guys need to figure out something that doesn't require phylib be 
built-in on ALL platforms, but only the platforms that require it.

Or, update the platform to not require built-in -- convert the board 
code to function pointers, and execute them later on somehow, for example.

	Jeff



