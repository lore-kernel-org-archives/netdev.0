From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/5] net: hwmon fixes
Date: Mon, 25 Nov 2013 09:48:23 -0800
Message-ID: <52938D67.2000401@roeck-us.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>	 <1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>	 <5290E0B9.1030606@roeck-us.net> <1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:53122 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228Ab3KYRsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 12:48:25 -0500
In-Reply-To: <1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2013 09:15 AM, Ben Hutchings wrote:
> On Sat, 2013-11-23 at 09:07 -0800, Guenter Roeck wrote:
>> On 11/23/2013 08:48 AM, Ben Hutchings wrote:
>>> On Fri, 2013-11-22 at 22:07 -0800, Guenter Roeck wrote:
>>>> The hwmon subsystem is used by various network drivers to report temperature
>>>> sensor and other information. Unfortunately, its use is often not correct.
>>>> Typical errors are that the mandatory name sysfs attribute is not created,
>>>> that the temperature sensor index starts with 0 instead of 1, and/or that
>>>> sysfs attributes are created after the hwmon device was created.
>>>
>>> As it happens, I was just looking at what we do in sfc
>>> (drivers/net/ethernet/sfc/mcdi_mon.c) and wondering why I made it create
>>> the hwmon device before the attributes.  I think I avoided the other
>>> bugs though.
>>>
>> Hi Ben,
>>
>> Yes, I know about that one. It concluded that it would be too invasive
>> and risky to try to fix it without access to hardware to test the results.
>> That is why I said "fixes _most_ of the problems".
>>
>> As for why the attributes are created after registration, it was most likely
>> because there was no API available to attach the sysfs attributes to
>> the hwmon device in a clean way. The new APIs fix that.
>
> We don't attach them to the hwmon device either, and I would rather not
> change that yet because lm-sensors 2 is still widely used.
>

Hmm .. then there should be no good reason to create the attributes
only after hwmon registration.

As for lm-sensors 2 ... really ? Seems odd that people would use the
latest kernel with 5+ years old versions of applications / libraries.
but I guess the world is full of such oddities, so maybe I should not
be surprised.

Note that the drivers in the hwmon subsystem are expected to move
to the new API over time, and some of them already did. New drivers
will likely not work with lm-sensors 2. So it may be time for those
still using lm-sensors 2 to consider an update, at least if they plan
to use those drivers with the latest kernel.

Thanks,
Guenter
