From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Port STP state after removing port from bridge
Date: Wed, 18 Feb 2015 21:28:28 -0800
Message-ID: <54E5747C.7050400@cumulusnetworks.com>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com> <54E56C6A.1060108@cumulusnetworks.com> <CAGVrzcbRO1f2Bt-fxSV0=DTnGdXTB-KeE=Kma2+0qgGkqc5n8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43210 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbbBSF23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 00:28:29 -0500
Received: by pdev10 with SMTP id v10so6375810pde.10
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 21:28:29 -0800 (PST)
In-Reply-To: <CAGVrzcbRO1f2Bt-fxSV0=DTnGdXTB-KeE=Kma2+0qgGkqc5n8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/18/15, 9:00 PM, Florian Fainelli wrote:
> 2015-02-18 20:54 GMT-08:00 roopa <roopa@cumulusnetworks.com>:
>> On 2/18/15, 8:39 PM, Florian Fainelli wrote:
>>> Hi,
>>>
>>> It just occured to me that the following sequence:
>>>
>>> brctl addbr br0
>>> brctl addif br0 port0
>>> ... STP happens
>>> brctl delif br0 port0
>>>
>>> will leave port0 in STP disabled state, because the bridge code will
>>> set the STP state to DISABLED, and only a down/up sequence can bring
>>> it back to FORWARDING.
>>>
>>> Is this something that we should somehow fix? As an user it seems a
>>> little convoluted having to do a down/up sequence to restore things. I
>>> believe however that it is valid for the bridge layer to mark a port
>>> as DISABLED when removing it. This is typically not noticed or even
>>> remotely a problem with software bridges because we cannot enforce an
>>> actual STP state at the HW level.
>>>
>> Just curious, Are you only talking about hw state being left it DISABLED
>> state in the switchdev context ?.
> Right, this is in the context of DSA using NET_SWITCHDEV.
>
>> If yes, then cant the switch driver who is already listening to port leave
>> msgs, clear the disabled state on the port. ?
> I guess that is definitively possible, I am not seeing that being done
> for rocker which I used as a model here, maybe that needs fixing there
> as well?

o ok, yes, the switch drivers can do it. In this case rocker can/should. 
Our driver does do the cleanup.
But if all drivers end up having this logic, it would maybe make sense 
to consider it doing it in the bridge driver delete port code.

Thanks,
Roopa
