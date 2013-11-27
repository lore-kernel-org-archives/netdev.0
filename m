From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/5] net: hwmon fixes
Date: Tue, 26 Nov 2013 19:28:19 -0800
Message-ID: <529566D3.8080801@roeck-us.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>		 <1385225290.20467.73.camel@deadeye.wl.decadent.org.uk>		 <5290E0B9.1030606@roeck-us.net>	 <1385399750.1586.40.camel@bwh-desktop.uk.level5networks.com>	 <52938D67.2000401@roeck-us.net> <1385496510.1586.63.camel@bwh-desktop.uk.level5networks.com>
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
Received: from mail.active-venture.com ([67.228.131.205]:52609 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3K0D2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 22:28:21 -0500
In-Reply-To: <1385496510.1586.63.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2013 12:08 PM, Ben Hutchings wrote:
> On Mon, 2013-11-25 at 09:48 -0800, Guenter Roeck wrote:
>> On 11/25/2013 09:15 AM, Ben Hutchings wrote:
>>> On Sat, 2013-11-23 at 09:07 -0800, Guenter Roeck wrote:
>>>> On 11/23/2013 08:48 AM, Ben Hutchings wrote:
>>>>> On Fri, 2013-11-22 at 22:07 -0800, Guenter Roeck wrote:
>>>>>> The hwmon subsystem is used by various network drivers to report temperature
>>>>>> sensor and other information. Unfortunately, its use is often not correct.
>>>>>> Typical errors are that the mandatory name sysfs attribute is not created,
>>>>>> that the temperature sensor index starts with 0 instead of 1, and/or that
>>>>>> sysfs attributes are created after the hwmon device was created.
>>>>>
>>>>> As it happens, I was just looking at what we do in sfc
>>>>> (drivers/net/ethernet/sfc/mcdi_mon.c) and wondering why I made it create
>>>>> the hwmon device before the attributes.  I think I avoided the other
>>>>> bugs though.
>>>>>
>>>> Hi Ben,
>>>>
>>>> Yes, I know about that one. It concluded that it would be too invasive
>>>> and risky to try to fix it without access to hardware to test the results.
>>>> That is why I said "fixes _most_ of the problems".
>>>>
>>>> As for why the attributes are created after registration, it was most likely
>>>> because there was no API available to attach the sysfs attributes to
>>>> the hwmon device in a clean way. The new APIs fix that.
>>>
>>> We don't attach them to the hwmon device either, and I would rather not
>>> change that yet because lm-sensors 2 is still widely used.
>>>
>>
>> Hmm .. then there should be no good reason to create the attributes
>> only after hwmon registration.
>>
>> As for lm-sensors 2 ... really ? Seems odd that people would use the
>> latest kernel with 5+ years old versions of applications / libraries.
>> but I guess the world is full of such oddities, so maybe I should not
>> be surprised.
> [...]
>
> As Jean pointed out, the net drivers implementing hwmon aren't supported
> by lm-sensors 2 anyway.  So we should go ahead and use the new API in
> sfc.  I've opened an internal bug report for this, but it is likely to
> be low priority for the team.  But if you write a patch I can test it.
>

You'll get one shortly.

Thanks,
Guenter
