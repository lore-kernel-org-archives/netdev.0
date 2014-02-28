From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port
 switch
Date: Fri, 28 Feb 2014 10:32:20 +0100
Message-ID: <531057A4.5020607@denx.de>
References: <1393492072-15364-1-git-send-email-sr@denx.de> <20140227.170240.1910151216729314077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, r.meier@siemens.com,
	lukas.stockmann@siemens.com, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.181]:60292 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbaB1Jcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 04:32:32 -0500
In-Reply-To: <20140227.170240.1910151216729314077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.02.2014 23:02, David Miller wrote:
> From: Stefan Roese <sr@denx.de>
> Date: Thu, 27 Feb 2014 10:07:52 +0100
>
>> This driver exposes a sysfs interface to access the LAN9303 registers to
>> userspace. These sysfs files can be used to configure the switch.
>>
>> Signed-off-by: Stefan Roese <sr@denx.de>
>
> We have an abstraction for programming switch devices called DSA.
>
> Even if DSA doesn't fullfill your needs, doing adjustments using sysfs
> files in userland is going to be the worst user experience possible.

DSA would have been optimal for us, as we really want to expose the 
external switch ports to the host cpu as (virtual) ethernet ports. But 
as Florian already mentioned, this switch does not support DSA. Only 
VLAN tagging with some special configuration options to make this setup 
possible for us.

I'm not sure but perhaps its possible to use the kernel DSA 
infrastructure for this switch after all? Are some non-DSA compatible 
switches supported right now? I could not find any reference for such 
non-DSA devices. Perhaps I missed something here.

> Every driver will export different things to tweak, each device will
> have different semantics and limitations for these settings, etc.
>
> Better is to come up with a real, types, interface for programming
> such devices and providing an implementation of that.

Right. Such a thing would be better. But as Florian already pointed out, 
nothing like this is available in kernel.org right now. Thats the reason 
why I chose to implement this "simple" driver, btw as done in 
drivers/net/phy/spi_ks8995.c.

Thanks,
Stefan
