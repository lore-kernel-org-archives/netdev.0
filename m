From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Fri, 20 Feb 2015 11:13:46 -0800
Message-ID: <54E7876A.3060303@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com> <54E76EFA.1050209@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	andrew@lunn.ch, gospo@cumulusnetworks.com, vbandaru@broadcom.com,
	siva.mannem.lnx@gmail.com
To: roopa <roopa@cumulusnetworks.com>, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35957 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbbBTTOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:14:07 -0500
Received: by pabkq14 with SMTP id kq14so10198395pab.3
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 11:14:06 -0800 (PST)
In-Reply-To: <54E76EFA.1050209@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/02/15 09:29, roopa wrote:
> On 2/19/15, 11:09 PM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
>> offload hardware.   Switchdev driver/devices can set this flag when
>> learning a
>> new FDB entry and SW (the bridge driver) will skip this entry when
>> running its
>> ageing task.  If flag is set, the driver/device is responsible for
>> calling
>> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry
>> expires.
>>
>> This give the flexibility for driver/device to decide ageing policy
>> based on
>> its capabilities.  For devices managing many FDB entries, it is
>> desireable for
>> the device to aged out its own entries.  Devices not capable of aged
>> entries
>> can rely of SW to age out the entries.
>>
> scott, patches look good. However, I am not sure yet if there is a need
> to make it a per fdb entry flag.

I agree, in fact, most of the HW I have access to only has a global age
timer configuration knob. Is this configurable on a per-port basis for
higher end switches, or even maybe per-FDB entry?

> 
> At some point we will also need the hw ageing parameter to be configurable.
> So other approach could be,
> - ageing parameter on bridge gets offloaded the hw
> - so, by default hw and kernel age their own entries using the same
> bridge device default timer
> - User can explicitly disable HW ageing by using self (this needs some
> more thought because now the call is on the bridge device)

I think we want to be careful with both SW and HW aging entries since a
host CPU's clock might be suspended/drifting etc.. at least, we probably
want one or the other to take precedence other the other one?
-- 
Florian
