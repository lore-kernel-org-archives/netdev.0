From: Vishal Thanki <vishalthanki@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 18:32:55 +0100
Message-ID: <CAC3a_SD=chB8pPpdRm8scztJ4592J26_PmhbUkLmbE3=DCmX-w@mail.gmail.com>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
 <20160317145032.GB26019@lunn.ch> <56EAE277.4050109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, Matus Ujhelyi <ujhelyi.m@gmail.com>,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36270 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030207AbcCQRdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:33:16 -0400
Received: by mail-lf0-f54.google.com with SMTP id d82so1500913lfe.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:33:15 -0700 (PDT)
In-Reply-To: <56EAE277.4050109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 5:59 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 17/03/16 07:50, Andrew Lunn wrote:
>> On Thu, Mar 17, 2016 at 02:59:07PM +0100, Vishal Thanki wrote:
>>> The LEDs can be turned on and off by a sysfs interface
>>> now. Write 0 to "led_enable" file to turn off the LEDs
>>> and write 1 to turn on. The support is experimental
>>> and can be enabled by kernel configuration option.
>>>
>>> Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
>>> ---
>>>  drivers/net/phy/Kconfig  |  7 +++++
>>>  drivers/net/phy/at803x.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++
>>
>> Hi Vishal
>>
>> This solution seems specific to the at803. You should be thinking of a
>> generic solution that all PHYs can use. eg add a new callback function
>> to phy_driver, and put the sysfs handling code in phylib.
>
> Indeed, maybe we should be considering using the existing LEDS subsystem
> (drivers/leds/*) to expose the PHY LEDs to user-space in a standard way?
> --

I agree with the idea of making a generic callback in phy_driver so
that other PHYs
can use it. However I think these LEDs are tightly coupled with PHYs and it
would not make much sense to expose them via LED subsystem as they
cannot be controlled individually IMHO.

> Florian
