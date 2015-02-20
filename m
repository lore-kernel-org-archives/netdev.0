From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging operations
Date: Thu, 19 Feb 2015 18:41:34 -0800
Message-ID: <54E69EDE.2030307@cumulusnetworks.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-3-git-send-email-f.fainelli@gmail.com> <54E54EF3.9020802@gmail.com> <20150219055953.GA14247@roeck-us.net> <54E61CFB.3010109@gmail.com> <20150219174640.GA6897@roeck-us.net> <54E676DD.9090003@gmail.com> <20150220000935.GA30118@roeck-us.net> <54E68512.6070108@cumulusnetworks.com> <20150220010352.GA300@roeck-us.net> <54E691F2.5090205@cumulusnetworks.com> <54E69536.3040303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42395 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbbBTClg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 21:41:36 -0500
Received: by padhz1 with SMTP id hz1so4416457pad.9
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 18:41:36 -0800 (PST)
In-Reply-To: <54E69536.3040303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/15, 6:00 PM, Florian Fainelli wrote:
> On 19/02/15 17:46, roopa wrote:
>> On 2/19/15, 5:03 PM, Guenter Roeck wrote:
>>> On Thu, Feb 19, 2015 at 04:51:30PM -0800, roopa wrote:
>>>>> Not sure yet what to do about setting the fdb aging time. I don't see a
>>>>> mechanism to do that. No idea how important that is.
>>>> rocker, the only consumer today relies on the bridge driver aging of
>>>> learnt
>>>> entries.
>>>> You could do the same.
>>>>
>>> Remember that we are dealing with hardware switch chips. Those chips
>>> won't time out fdb entries just because the kernel's bridge driver
>>> thinks that it should.
>> Oh, they dont..?. sorry,  I dont know the details about your hardware.
>> But, if these are entries learnt by hw, there should be a hw config to
>> age them (I guess that is what you are talking about). Which the swicth
>> driver can set.
>> If you disable hw aging, you can sync these entries to the bridge
>> driver, and make the bridge driver age them followed by a subsequent
>> delete in hw.
> The SF2 HW has and aging and a valid bit available, I guess my question
> would be, do we have anything today in "net-next" that allows
> configuring HW aging vs. SW aging (implying doing a HW to SW sync)?


There is no config parameter to set HW aging vs SW aging. But if you 
want SW aging, an example is the rocker implementation today.
And there is BR_LEARNING_SYNC per bridge port flag to sync HW to SW 
using notifiers (see rocker).

There is no netlink based age time sets AFAIK. But there is age time 
sets from sysctl. And there is no offload support for this today.
The offload support has been discussed previously and there was no need 
to add it immediately.
