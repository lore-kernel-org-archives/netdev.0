From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Thu, 06 Jul 2006 11:25:54 -0700
Message-ID: <44AD55B2.3030900@intel.com>
References: <1152033116.5276.22.camel@jzny2>	 <1152040839.5276.25.camel@jzny2>	 <20060705.112237.41652489.davem@davemloft.net> <44AC05A8.9030503@intel.com>	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl> <1152191018.5103.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, jgarzik@pobox.com,
	greearb@candelatech.com, john.ronciak@intel.com,
	Robert.Olsson@data.slu.se, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56644 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1750728AbWGFSlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 14:41:17 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152191018.5103.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2006-05-07 at 22:45 +0200, Krzysztof Oledzki wrote:
>> On Wed, 5 Jul 2006, Auke Kok wrote:
>>
>>> David Miller wrote:
>>>> Flow control has been on by default in the tg3 driver since the
>>>> beginning,
> 
> Are you sure about this Dave?;-> because I do have a tg3 on my laptop.
> 
> hadi@jzny2:~/Desktop/maemo$ sudo ethtool -a eth0
> Pause parameters for eth0:
> Autonegotiate:  on
> RX:             off
> TX:             off

mine says it's on :)

> Maybe it is read from the eeprom and mine has it off?
> 
> Again, note that: It is consuming > 10% (13-15% range) of my bandwidth.
> Granted that is at high speeds with small packets so may not be
> reflective of 96% of the world. But that would be > 50kpps of my
> forwarding capacity being chewed unreasonably. So Auke, did you say
> "performance" was what people mostly bitched about? ;->

yes, but that's linked with hardware that doesn't handle flowcontrol events 
properly, if you were doing large message TCP transfers over that you'd 
probably see even worse performance I bet (retransmits being dropped etc).

Jesse is working on performance stuff, he'll gladly look into it :)

>>> As said earlier, e1000 always honors the EEPROM setting for this, which has 
>>> been _on_ by default for all cards (AFAIK, that is).
> 
> It has _never ever_ worked on e1000 for as long as i have used e1000. If
> it was intended to work, it must have been fixed in 2.6.16. So it is new
> behavior.

Turns out that of the e1000 cards I can find around here that are plugged in 
actually are 50-50 distributed on/off, so I was wrong about it being on by 
default everywhere.

Looking back through the code I see no changes affecting flow control setup as 
early as 2.6.12 ... There are some minor (new) HW changes but nothing that 
should have boken fc.

Cheers,

Auke
