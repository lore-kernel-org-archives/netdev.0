From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 21:30:33 +0200
Message-ID: <5526D359.1050202@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr> <5526CC5A.1080504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:36224 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758AbbDITao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 15:30:44 -0400
In-Reply-To: <5526CC5A.1080504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> Mason wrote:
>> Florian Fainelli wrote:
>>
>>> Mason wrote:
>>>
>>>> Is speed auto-negotiation supposed to be complete when phy_init_hw exits?
>>>
>>> There is no such guarantee, and the PHY state machine is started later,
>>> which will take care of auto-neg and other things.
>>
>> That's what I thought.
>>
>> So it's expected that many status bits will only change later.
>>
>> You didn't comment on my patch. What's your take on it?
> 
> Quoting IEEE 802.3 section 2, paragraph 22.2.4.1:
> 
> "Resetting a PHY is accomplished by setting bit 0.15 to a logic one.
> This action shall set the status and control registers to their 
> default states. As a consequence this action may change the internal 
> state of the PHY and the state of the physical link associated with 
> the PHY. This bit is self-clearing, and a PHY shall return a value
> of one in bit 0.15 until the reset process is completed. A PHY is
> not required to accept a write transaction to the control register 
> until the reset process is completed, and writes to bits of the 
> control register other than 0.15 may have no effect until the reset 
> process is completed. The reset process shall be completed within
> 0.5 s from the setting of bit 0.15"
> 
> So even though this is not extremely specific about whether or not doing
> a RMW instead of W is accepted, considering that this resets the PHY
> internal state, and the fact that there is a lack of clarify on whether
> setting any bits other than 15 is going to fall under the "A PHY is not
> required to accept a write transaction to the control register until the
> reset process is completed" statement, setting only this bit at least
> guarantees that you are back into your reset defaults.
> 
> As Daniel suggested, I would be looking for undocumented/proprietary
> registers for reasons as to why your PHY is not working, in particular
> (RG)MII tuning.

Am I the only having problems with the AR8035? :-(

The standard driver works for everyone but me? 

Did you take a look at the data sheet? Do you understand the
difference between "Hardware Reset" and "Software Reset"?

Maybe on my PHY, writing BMCR_RESET to BMCR triggers a SW reset,
while it triggers a HW reset on other boards?

Would that be possible?

Also, why do you say the PHY is not working? When I apply the
patch I proposed, it doesn't malfunction.

Regards.
