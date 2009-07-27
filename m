From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] Add Support for Freescale FlexCAN CAN controller
Date: Mon, 27 Jul 2009 12:52:37 +0200
Message-ID: <4A6D86F5.7030707@hartkopp.net>
References: <20090724131933.GL2714@pengutronix.de>	<4A69CB46.1090704@grandegger.com>	<20090727062559.GP2714@pengutronix.de>	<4A6D727B.7030304@grandegger.com> <4A6D76B7.8030105@hartkopp.net> <4A6D7C7E.9050703@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:43864 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbZG0Kwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 06:52:41 -0400
In-Reply-To: <4A6D7C7E.9050703@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Oliver Hartkopp wrote:
>> Wolfgang Grandegger wrote:
>>> Sascha Hauer wrote:
>>>> On Fri, Jul 24, 2009 at 04:55:02PM +0200, Wolfgang Grandegger wrote:
>>
>>> [...]
>>>>>> +	kfree_skb(skb);
>>>>> Support for echo skb using can_put/get_echo_skb() is missing. It should
>>>>> not be a big deal to add it.
>>>> In fact it's not missing, but the hardware is configured to receive its
>>>> own packets, so this isn't needed.
>>> But the user may disable IFF_ECHO, which should be handled somehow.
>> Really?
>>
>> IMO IFF_ECHO indicates the capability of the network driver to perform the MAC
>> layer frame echo on driver level.
>>
>> Only when you have a CAN driver that does not have this capability (the 'bad'
>> non default case) this flag is cleared.
>>
>> There is no need to provide a mode that can switch this functionality 'on' and
>> 'off'. IFF_ECHO is just an indication provided by the driver.
>>
>> When the FlexCAN controller can 'receive' a sent frame, so that it reflects
>> the correct message order on the bus, this is perfect.
>>
>> In this case Sascha should set the IFF_ECHO flag and he's done.
> 
> I thought the user can toggle the IFF_ECHO flag with the "ip" utility,
> but obviously I'm wrong.

AFAIK the only driver that currently allows to switch this flag is the vcan
driver - but this is for testing purposes only and can be configured by the
module commandline.

I assume having the echo functionality runtime configurable is only effort and
complicates the driver ...

Best regards,
Oliver

