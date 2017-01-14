From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 05/10] drivers: base: Add device_find_class()
Date: Sat, 14 Jan 2017 11:01:14 -0800
Message-ID: <0f5e5265-b116-286c-4d72-3aaa72ae83ac@gmail.com>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
 <20170112034121.27697-6-f.fainelli@gmail.com>
 <20170112.162135.441956368122992032.davem@davemloft.net>
 <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02620D3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: David Laight <David.Laight@ACULAB.COM>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35177 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdANTBS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 14:01:18 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02620D3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/13/2017 02:55 AM, David Laight wrote:
> From: Florian Fainelli
>> Sent: 12 January 2017 22:51
>> On 01/12/2017 01:21 PM, David Miller wrote:
>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>> Date: Wed, 11 Jan 2017 19:41:16 -0800
>>>
>>>> Add a helper function to lookup a device reference given a class name.
>>>> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
>>>> make it more generic.
> ...
>>>> +static int dev_is_class(struct device *dev, void *class)
>>>
>>> I know you are just moving code, but this class argumnet is a string
>>> and thus should be "char *" or even "const char *".
>>
>> Well, this is really so that we don't need to cast the arguments passed
>> to device_find_child(), which takes a void *data as well. If we made
>> that a const char *class, we'd get warnings that look like these:
>>
>> drivers/base/core.c: In function 'device_find_class':
>> drivers/base/core.c:2083:2: warning: passing argument 2 of
>> 'device_find_child' discards 'const' qualifier from pointer target type
>> [enabled by default]
>>   return device_find_child(parent, class, dev_is_class);
>>   ^
>> drivers/base/core.c:2050:16: note: expected 'void *' but argument is of
>> type 'const char *'
>>  struct device *device_find_child(struct device *parent, void *data,
>>                 ^
> ...
> 
> Maybe device_find_child() needs changing to take 'const void *' ?

As a separate patch set, sure, I will add that to my TODO. Thanks!
-- 
Florian
