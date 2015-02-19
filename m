From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging operations
Date: Thu, 19 Feb 2015 09:27:23 -0800
Message-ID: <54E61CFB.3010109@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-3-git-send-email-f.fainelli@gmail.com> <54E54EF3.9020802@gmail.com> <20150219055953.GA14247@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43138 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbBSR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 12:27:38 -0500
Received: by pdev10 with SMTP id v10so1097479pde.10
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 09:27:38 -0800 (PST)
In-Reply-To: <20150219055953.GA14247@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/15 21:59, Guenter Roeck wrote:
> On Wed, Feb 18, 2015 at 06:48:19PM -0800, Florian Fainelli wrote:
>> On 17/02/15 11:26, Florian Fainelli wrote:
>>> Update the Broadcom Starfighter 2 switch driver to implement the
>>> join/leave/stp_update callbacks required for basic hardware bridging
>>> support.
>>>
>>> There is not much to be done at the driver level but translating the
>>> STP state from Linux to their HW values.
>>>
>>> Joining a bridge means that the joining port and the other port members
>>> need to be in the same VLAN membership as the CPU, while leaving the
>>> bridge puts the port back into a separate VLAN membership with only the
>>> CPU.
>>
>> I found a couple additional issues while testing:
>>
>> - manipulating UP/DOWN state of interfaces that are part of a bridge
>> would not restore their bridge membership
>>
>> - removing an interface from a bridge and bringing it back up would
>> leave it in blocked state
>>
> Is this a problem with your implementation for sf2 or a generic problem
> with the first patch, such as some missing state transitions ?

This is more of a side effect of having HW (an Ethernet switch) that can
really block a given port, based on last night's discussion with Roopa,
we can either fix this at the DSA level (in our case) or better fix this
at the bridge layer, I will propose a fix for this shortly.

> 
> For sf2, you might have to set the port state as well as the bridge
> association in the port_setup function. That is of course just a
> wild guess.

Right, that's what I ended up doing. Thanks!
-- 
Florian
