From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: dsa: restore HWMON support in dsa2
Date: Tue, 3 Jan 2017 11:29:48 -0800
Message-ID: <0a504cad-2f2c-fc6a-9965-5ae87be9dac4@gmail.com>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
 <20170103183352.GA30638@lunn.ch>
 <87ful0eylp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>, cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36350 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbdACT3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 14:29:51 -0500
In-Reply-To: <87ful0eylp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/2017 11:24 AM, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> On Tue, Jan 03, 2017 at 01:15:35PM -0500, Vivien Didelot wrote:
>>> The current HWMON support in DSA in embedded in the legacy code.
>>> Extract it to its own file and register it in the newer DSA code.
>>
>> I would really prefer not to do this.
>>
>> The temperature sensor is in the embedded PHYs of the switch. Many of
>> Marvell discrete PHYs also have the same temperature sensor. The
>> correct thing to do is move this code into drivers/net/phy/marvell.c.
> 
> I agree that the temperature code in the mv88e6xxx driver must be moved
> to the Marvell PHY driver.
> 
> However I still think this patchset is still valuable because at least
> it isolates the HWMON code in DSA which is good, and I think some chips
> do have temperature sensors in their cores, not in their PHYs. So the
> new DSA code should benefit from the HWMON support instead of
> considering this a regression for its users.

Well, I agree with the regression part, but an argument could
definitively be made that HWMON did not belong in the DSA layer in the
first place, unless we were able to find some commonality between
devices which AFAICT, we could not yet.

I don't have a strong preference, but it seems like the HWMON
functionality should have been part of the switch and/or PHY driver all
along.
-- 
Florian
