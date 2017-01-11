From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 09:55:49 -0800
Message-ID: <0148fe14-a6aa-7f96-6244-74103de05879@gmail.com>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170111173741.GB13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Guenter Roeck <linux@roeck-us.net>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35677 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938951AbdAKRz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 12:55:57 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so7531928pge.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 09:55:57 -0800 (PST)
In-Reply-To: <20170111173741.GB13033@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2017 09:37 AM, Andrew Lunn wrote:
> On Wed, Jan 11, 2017 at 12:06:11PM -0500, Vivien Didelot wrote:
>> Hi Andrew,
>>
>> Andrew Lunn <andrew@lunn.ch> writes:
>>
>>> Marvell Ethernet switches contain temperature sensors. They are inside
>>> the embedded PHYs. Move the code into the PHY driver, so that discrete
>>> PHY drivers also export there temperature sensor.
>>
>> This message is not correct. The Marvell Ethernet switches contain only
>> one temperature sensor for the entire chip (please adjust the cover
>> letter and commit messages when you respin.)
> 
> Agreed.
> 
>> The temperature and threshold are accessed through the embedded PHY
>> registers of any port, as long as the port is not disabled.
> 
> This is not correct. Each PHY has its own threshold registers. They
> can be different, even if they are applied to one shared sensor.  One
> PHY can be in alarm state, while others are not, due to different
> thresholds.
> 
>> Even unlikely to be used, an interrupt can be generated when the
>> temperature exceeds a certain threshold. It should be enabled on only
>> one port at a time since there is only one temperature sensor.
> 
> Actually, since each PHY can have a different threshold, it would in
> theory be possible to have different PHYs generating interrupts at
> different thresholds.
> 
> However, at the moment, there is no code to enable interrupts for
> temperature alarms. I also don't see any need to add such code, since
> there is nowhere in HWMON to actively report such an alarm condition.

Are not the *_alarm attributes specifically designed to report such
things? See Documentation/hwmon/sysfs-interface

> 
> There is potentially an issue sometime down the road, if we were to
> enable the temperature threshold interrupt. It is not clear what
> happens if two PHYs have the same threshold conditions and this
> threshold is crossed. Do all PHYs trigger an interrupt? Does only one?
> Do none? I would prefer investigating and solving such issues if and
> when it is decided to enable the interrupt.
> 
>> To sum up briefly, the temperature chip is physically inside the switch
>> chip, but its access is via the embedded PHYs of the switch.
> 
> There is one temperature sensor in the chip, which each embedded PHY
> shares for reporting the current temperature. It appears that
> everything but the sensor is duplicated in each embedded PHY.

If that is the case, should we have a way to make the HWMON attributes
be associated with the switch device while still calling into the PHY
driver to do the actual temperature readings and such? Right now, it
sounds like we will have a duplication of HWMON attributes created for
every port of the switch that is connecting to the Marvell PHY driver.
-- 
Florian
