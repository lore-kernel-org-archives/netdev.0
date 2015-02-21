From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 12:03:59 +0100
Message-ID: <20150221110359.GA2095@nanopsycho.orion>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <54E76EFA.1050209@cumulusnetworks.com>
 <54E7876A.3060303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch,
	gospo@cumulusnetworks.com, vbandaru@broadcom.com,
	siva.mannem.lnx@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:44082 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbbBULED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 06:04:03 -0500
Received: by wesk11 with SMTP id k11so9777370wes.11
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 03:04:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54E7876A.3060303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 20, 2015 at 08:13:46PM CET, f.fainelli@gmail.com wrote:
>On 20/02/15 09:29, roopa wrote:
>> On 2/19/15, 11:09 PM, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
>>> offload hardware.   Switchdev driver/devices can set this flag when
>>> learning a
>>> new FDB entry and SW (the bridge driver) will skip this entry when
>>> running its
>>> ageing task.  If flag is set, the driver/device is responsible for
>>> calling
>>> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry
>>> expires.
>>>
>>> This give the flexibility for driver/device to decide ageing policy
>>> based on
>>> its capabilities.  For devices managing many FDB entries, it is
>>> desireable for
>>> the device to aged out its own entries.  Devices not capable of aged
>>> entries
>>> can rely of SW to age out the entries.
>>>
>> scott, patches look good. However, I am not sure yet if there is a need
>> to make it a per fdb entry flag.
>
>I agree, in fact, most of the HW I have access to only has a global age
>timer configuration knob. Is this configurable on a per-port basis for
>higher end switches, or even maybe per-FDB entry?

I'm currently not aware of any hw which does not have global age timer.
But I believe that they will appear. The model that we have now, to
propagate aging setting of bridge down is more general and should be ok.

Drivers should probably take care of multi bridge setup with different
aging setup. Maybe to find minimal time and print a warning?

>
>> 
>> At some point we will also need the hw ageing parameter to be configurable.
>> So other approach could be,
>> - ageing parameter on bridge gets offloaded the hw
>> - so, by default hw and kernel age their own entries using the same
>> bridge device default timer
>> - User can explicitly disable HW ageing by using self (this needs some
>> more thought because now the call is on the bridge device)
>
>I think we want to be careful with both SW and HW aging entries since a
>host CPU's clock might be suspended/drifting etc.. at least, we probably
>want one or the other to take precedence other the other one?
>-- 
>Florian
