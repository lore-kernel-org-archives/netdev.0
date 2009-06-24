From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: let SJA1000 driver depend on HAS_IOMEM
Date: Wed, 24 Jun 2009 10:35:59 +0200
Message-ID: <4A41E56F.6030302@hartkopp.net>
References: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com>	<4A412C53.8050607@grandegger.com>	<4A41CD36.8030202@hartkopp.net> <20090624.000109.49664041.davem@davemloft.net> <4A41E31B.1030703@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, heiko.carstens@de.ibm.com,
	schwidefsky@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:62669 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbZFXIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:36:06 -0400
In-Reply-To: <4A41E31B.1030703@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> David Miller wrote:
>> From: Oliver Hartkopp <socketcan@hartkopp.net>

>>> the question is, if we should add HAS_IOMEM to almost every SJA1000 depended
>>> driver like SJA1000_PLATFORM, SJA1000_OF_PLATFORM, EMS_PCI and KVASER_PCI ???
>>>
>>> Is it possible to have a support for the SJA1000 that does *not* depend on
>>> HAS_IOMEM?
>
> In principle yes by using an appropriate driver accessing the SJA1000
> with other methods. But I might be wrong because it does not make sense
> hardware-wise.
>
>> This was my initial impression when I saw Wolfgang's suggested patch,
>> and I still feel this way, and thus Heiko's patch seems the best for
>> now until there is an exception.
>>
>> And in fact Heiko's patch has been in my tree for a while already :)
>
> OK, that's fine for the moment. We may even consider making CONFIG_CAN
> depend on HAS_IOMEM like for SPI, USB, Serial, etc.

Why CONFIG_CAN ??

CONFIG_CAN provides a network protocol family that can be used e.g. with the
vcan driver without any hardware. So HAS_IOMEM only has to take care of some
drivers, that fiddle on CAN controller registers themselves. E.g. for SPI, USB
and Serial these 'underlying' interfaces bring their own requirements. When we
depend on SPI, it should bring HAS_IOMEM as a dependency of SPI.

Regards,
Oliver


