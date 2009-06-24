From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: let SJA1000 driver depend on HAS_IOMEM
Date: Wed, 24 Jun 2009 10:26:03 +0200
Message-ID: <4A41E31B.1030703@grandegger.com>
References: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com>	<4A412C53.8050607@grandegger.com>	<4A41CD36.8030202@hartkopp.net> <20090624.000109.49664041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, heiko.carstens@de.ibm.com,
	schwidefsky@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54529 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbZFXI0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:26:05 -0400
In-Reply-To: <20090624.000109.49664041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Wed, 24 Jun 2009 08:52:38 +0200
> 
>> Wolfgang Grandegger wrote:
>>> Heiko Carstens wrote:
>>
>>>> Index: linux-2.6/drivers/net/can/Kconfig
>>>> ===================================================================
>>>> --- linux-2.6.orig/drivers/net/can/Kconfig
>>>> +++ linux-2.6/drivers/net/can/Kconfig
>>>> @@ -36,7 +36,7 @@ config CAN_CALC_BITTIMING
>>>>  	  If unsure, say Y.
>>>>  
>>>>  config CAN_SJA1000
>>>> -	depends on CAN_DEV
>>>> +	depends on CAN_DEV && HAS_IOMEM
>>>>  	tristate "Philips SJA1000"
>>>>  	---help---
>>>>  	  Driver for the SJA1000 CAN controllers from Philips or NXP
>>> Hm, this Kconfig entry is not directly responsible for building
>>> sja1000_platform.o. It builds sja1000.o, which does not rely on
>>> HAS_IOMEM. It should be added to "config CAN_SJA1000_PLATFORM" instead.
>> Hi Wolfgang,
>>
>> the question is, if we should add HAS_IOMEM to almost every SJA1000 depended
>> driver like SJA1000_PLATFORM, SJA1000_OF_PLATFORM, EMS_PCI and KVASER_PCI ???
>>
>> Is it possible to have a support for the SJA1000 that does *not* depend on
>> HAS_IOMEM?

In principle yes by using an appropriate driver accessing the SJA1000
with other methods. But I might be wrong because it does not make sense
hardware-wise.

> This was my initial impression when I saw Wolfgang's suggested patch,
> and I still feel this way, and thus Heiko's patch seems the best for
> now until there is an exception.
> 
> And in fact Heiko's patch has been in my tree for a while already :)

OK, that's fine for the moment. We may even consider making CONFIG_CAN
depend on HAS_IOMEM like for SPI, USB, Serial, etc.

Wolfgang.
Woflgang.
