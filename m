From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/3] net: dsa: restore HWMON support in dsa2
Date: Tue, 03 Jan 2017 14:41:58 -0500
Message-ID: <87bmvo9bi1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com> <20170103183352.GA30638@lunn.ch> <87ful0eylp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <0a504cad-2f2c-fc6a-9965-5ae87be9dac4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>, cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51476 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935682AbdACTmP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 14:42:15 -0500
In-Reply-To: <0a504cad-2f2c-fc6a-9965-5ae87be9dac4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>>>> The current HWMON support in DSA in embedded in the legacy code.
>>>> Extract it to its own file and register it in the newer DSA code.
>>>
>>> I would really prefer not to do this.
>>>
>>> The temperature sensor is in the embedded PHYs of the switch. Many of
>>> Marvell discrete PHYs also have the same temperature sensor. The
>>> correct thing to do is move this code into drivers/net/phy/marvell.c.
>> 
>> I agree that the temperature code in the mv88e6xxx driver must be moved
>> to the Marvell PHY driver.
>> 
>> However I still think this patchset is still valuable because at least
>> it isolates the HWMON code in DSA which is good, and I think some chips
>> do have temperature sensors in their cores, not in their PHYs. So the
>> new DSA code should benefit from the HWMON support instead of
>> considering this a regression for its users.
>
> Well, I agree with the regression part, but an argument could
> definitively be made that HWMON did not belong in the DSA layer in the
> first place, unless we were able to find some commonality between
> devices which AFAICT, we could not yet.
>
> I don't have a strong preference, but it seems like the HWMON
> functionality should have been part of the switch and/or PHY driver all
> along.

I see what you mean. Indeed the drivers could register their own HWMON
device until we figure any many chips have an embedded temperature
sensor in their core.

What about sending the patch 2/3 on its own?

Thanks,

        Vivien
