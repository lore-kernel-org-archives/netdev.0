From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Wed, 27 May 2015 22:01:03 -0700
Message-ID: <5566A10F.8060603@roeck-us.net>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com> <20150526225142.GB26454@roeck-us.net> <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com> <556630EA.7060707@roeck-us.net> <20150527210523.GE31127@lunn.ch> <55664A8F.6040006@roeck-us.net> <20150528014622.GD9751@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Chris Healy <cphealy@gmail.com>,
	=?windows-1252?Q?J=E9rome_Oufella?=
	<jerome.oufella@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37470 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbE1FBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 01:01:08 -0400
In-Reply-To: <20150528014622.GD9751@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 06:46 PM, Andrew Lunn wrote:
> On Wed, May 27, 2015 at 03:51:59PM -0700, Guenter Roeck wrote:
>> On 05/27/2015 02:05 PM, Andrew Lunn wrote:
>>>> Do you have lock debugging enabled in your code ? I am getting a recursive
>>>> lock warning due to a recursive call to dev_mc_sync(). I think we may have
>>>> to implement lock nesting for dsa, similar to how it id done for vlan
>>>> support, but I have not been able to figure out how exactly it works yet.
>>>
>>> I might be able to help, since i solve two similar problems already in
>>> DSA, one for MDIO bus, and a second one for transmit buffers.
>>>
>>>       Andrew
>>>
>> What I did is to create a vlan interface on one of the dsa slave ports
>> and enabling it.
>>
>> This results in a call to dev_mc_sync() on the dsa interface, which is passed
>> on to the real interface. dev_mc_sync() calls netif_addr_lock_nested(to),
>> which results in the recursive lock message.
>>
>>   ifconfig/2291 is trying to acquire lock:
>>    (_xmit_ETHER/1){+.....}, at: [<ffffffff8175b757>] dev_mc_sync+0x57/0xa0
>>
>>   but task is already holding lock:
>>    (_xmit_ETHER/1){+.....}, at: [<ffffffff8175b757>] dev_mc_sync+0x57/0xa0
>>
>>   other info that might help us debug this:
>>    Possible unsafe locking scenario:
>>
>>          CPU0
>>          ----
>>     lock(_xmit_ETHER/1);
>>     lock(_xmit_ETHER/1);
>>
>> Pretty much inevitable as far as I can see.
>
> It looks like DSA needs to implement ndo_get_lock_subclass().
>
> We can probably copy the code from macvlan.c.
>

Not entirely, but I think I have an idea. I'll give it a try.

Guenter
