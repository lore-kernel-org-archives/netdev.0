From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: let SJA1000 driver depend on HAS_IOMEM
Date: Wed, 24 Jun 2009 00:01:09 -0700 (PDT)
Message-ID: <20090624.000109.49664041.davem@davemloft.net>
References: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com>
	<4A412C53.8050607@grandegger.com>
	<4A41CD36.8030202@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, heiko.carstens@de.ibm.com,
	schwidefsky@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49219
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbZFXHBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 03:01:04 -0400
In-Reply-To: <4A41CD36.8030202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 24 Jun 2009 08:52:38 +0200

> Wolfgang Grandegger wrote:
>> Heiko Carstens wrote:
> 
> 
>>> Index: linux-2.6/drivers/net/can/Kconfig
>>> ===================================================================
>>> --- linux-2.6.orig/drivers/net/can/Kconfig
>>> +++ linux-2.6/drivers/net/can/Kconfig
>>> @@ -36,7 +36,7 @@ config CAN_CALC_BITTIMING
>>>  	  If unsure, say Y.
>>>  
>>>  config CAN_SJA1000
>>> -	depends on CAN_DEV
>>> +	depends on CAN_DEV && HAS_IOMEM
>>>  	tristate "Philips SJA1000"
>>>  	---help---
>>>  	  Driver for the SJA1000 CAN controllers from Philips or NXP
>> 
>> Hm, this Kconfig entry is not directly responsible for building
>> sja1000_platform.o. It builds sja1000.o, which does not rely on
>> HAS_IOMEM. It should be added to "config CAN_SJA1000_PLATFORM" instead.
> 
> Hi Wolfgang,
> 
> the question is, if we should add HAS_IOMEM to almost every SJA1000 depended
> driver like SJA1000_PLATFORM, SJA1000_OF_PLATFORM, EMS_PCI and KVASER_PCI ???
> 
> Is it possible to have a support for the SJA1000 that does *not* depend on
> HAS_IOMEM?

This was my initial impression when I saw Wolfgang's suggested patch,
and I still feel this way, and thus Heiko's patch seems the best for
now until there is an exception.

And in fact Heiko's patch has been in my tree for a while already :)
