From: Vishal Thanki <vishalthanki@gmail.com>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Wed, 23 Mar 2016 22:24:45 +0100
Message-ID: <CAC3a_SBjvQFT5XP2bH3TO_4wHnjZ3a3+XvfBy8StxQieEsavQQ@mail.gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160323185006.GL5250@lunn.ch> <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
 <20160323211010.GF19953@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34544 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756792AbcCWVZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 17:25:06 -0400
Received: by mail-lf0-f48.google.com with SMTP id c62so17821545lfc.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 14:25:05 -0700 (PDT)
In-Reply-To: <20160323211010.GF19953@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 10:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Mar 23, 2016 at 09:24:00PM +0100, Vishal Thanki wrote:
>> Hi,
>>
>> > My suggestion was that the hardware needs to control the LEDs. You
>> > have software doing it. You might be able to do this with the PHY
>> > state machine for link. But activity is never going to be accepted if
>> > software control.
>> >
>> > The LED trigger attached to an LED should be used to configure the
>> > hardware to drive the LED as wanted.
>> >
>>
>> The eth-phy-activity trigger uses the blink_set which I think uses the
>> hardware acceleration if available. I am not sure how to handles LEDs
>> which does not have hardware acceleration for this (eth-phy-activity)
>> trigger.
>
> We want the LED to blink on activity, real packets coming in and
> out. The PHY can do this, so let the PHY control the LED. In this
> case, the trigger is just mechanism for the user to say what the LED
> should be used for. The trigger is not itself controlling the LED, it
> has no idea about packets coming and going.
>

Yes, I understand that. But PHY can only control the LEDs attached to
it directly. The at803x led driver configures the PHY to blink the
activity LED based on traffic but I think it is not possible for PHY
to control other LEDs in system, for example some other LEDs in system
controlled only via GPIO. In such cases, putting PHY activity trigger
on the GPIO LEDs would not make sense. Correct me if I am wrong.

Vishal
