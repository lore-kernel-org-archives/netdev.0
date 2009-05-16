From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 4/7] [PATCH 4/8] can: Driver for the SJA1000 CAN controller
Date: Sat, 16 May 2009 08:57:03 +0200
Message-ID: <4A0E63BF.9080503@grandegger.com>
References: <20090512092757.048938233@denx.de>	<20090512092757.756749047@denx.de>	<20090513155205.4bf06c25@bike.lwn.net>	<4A0BDE79.4060606@grandegger.com> <20090515143927.7ba06f10@bike.lwn.net> <4A0DDD81.4040406@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49616 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbZEPG5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 02:57:14 -0400
In-Reply-To: <4A0DDD81.4040406@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Jonathan Corbet wrote:
>> On Thu, 14 May 2009 11:03:53 +0200
>> Wolfgang Grandegger <wg@grandegger.com> wrote:
>>
>>>> So you're still using the "put the higher-level structure at the top so we
>>>> can treat it like either kind of pointer" trick.  I'd still recommend
>>>> against that.  Far better to do something like:
>>>>
>>>> 	struct can_priv *canpriv = netdev_priv(dev);
>>>> 	struct sja_1000_priv *priv = container_of(canpriv, struct sja_1000_priv, can);
>>>>
>>>> Of course, you can put that dance into a helper function.  
>>> There is no way to initialize the value returned by netdev_priv() as it
>>> does not point to a member of struct net_device. I already commented here:
>>>
>>>   http://marc.info/?l=linux-netdev&m=124120212106891&w=2
>>>
>>> Have I missed something?
>> I'm confused.  It points to the struct can_priv that you registered at
>> the beginning.  Since that structure is contained within struct
>> sja1000_priv, you can use container_of(), as described above, to get
>> it.
>>
>> I would probably just write something like:
>>
>> static inline struct sja1000_priv *to_sja1000_priv(struct net_device *dev)
>> {
>> 	return container_of(netdev_priv(dev), struct sja1000_priv, can);
>> }
>>
>> So have *I* missed something?
> 
> Furthermore, the higher layer needs to known the location of the member
> "struct sja1000_priv can", e.g. by defining:
> 
>   dev->priv = &dev_specific_priv->can;
> 
> But "struct net_device" does not have a "priv" member. netdev_priv(dev)
> always points to the beginning of the private data area. See:
> 
>    http://lxr.linux.no/linux+v2.6.29/include/linux/netdevice.h#L953

I could use container_of() as you suggested, of course, if the "struct
can_priv" remains the first member of  "struct sja1000_priv". Would that
already be an improvement?

Wolfgang.
