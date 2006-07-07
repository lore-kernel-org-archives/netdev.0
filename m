From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Thu, 06 Jul 2006 23:09:18 -0400
Message-ID: <1152241758.5341.9.camel@jzny2>
References: <1152033116.5276.22.camel@jzny2>
	 <1152040839.5276.25.camel@jzny2>
	 <20060705.112237.41652489.davem@davemloft.net> <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	 <1152191018.5103.48.camel@jzny2>  <44AD55B2.3030900@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:57742 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751159AbWGGDJY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 23:09:24 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fygih-00056e-Fc
	for netdev@vger.kernel.org; Thu, 06 Jul 2006 23:09:31 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44AD55B2.3030900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-07 at 11:25 -0700, Auke Kok wrote:
> jamal wrote:

> > hadi@jzny2:~/Desktop/maemo$ sudo ethtool -a eth0
> > Pause parameters for eth0:
> > Autonegotiate:  on
> > RX:             off
> > TX:             off
> 
> mine says it's on :)


Dell D610:
hadi@jzny2:~$ sudo lspci | grep -i bcm
0000:02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5751
Gigabit Ethernet PCI Express (rev 01)

Whats yours?
So ok, from what you say below i take it that even with the e1000s
you didnt find consistency on different machines.
Can you double check at least the kernels are >= 2.6.16?
I can tell you this hardware that caused me problems never had flow
control working in the earlier kernels.

> > Maybe it is read from the eeprom and mine has it off?
> > 
> > Again, note that: It is consuming > 10% (13-15% range) of my bandwidth.
> > Granted that is at high speeds with small packets so may not be
> > reflective of 96% of the world. But that would be > 50kpps of my
> > forwarding capacity being chewed unreasonably. So Auke, did you say
> > "performance" was what people mostly bitched about? ;->
> 
> yes, but that's linked with hardware that doesn't handle flowcontrol events 
> properly, 

As i mentioned earlier: This is actually hardware that works with flow
control ;->
When it doesnt work - as in the case of the one i found advertising but
not respecting flow control the bandwidth being consumed was > 60% ;->
To give you perspective, on average that is > 500Mbps

> if you were doing large message TCP transfers over that you'd 
> probably see even worse performance I bet (retransmits being dropped etc).
> 

I havent tested that, but it does seem unlikely.

> Jesse is working on performance stuff, he'll gladly look into it :)
> 

Jesse, if you want to reproduce this talk to me and i will give you a
description of how to do it. Make sure you can record flow control
packets both in send and receive.


> >>> As said earlier, e1000 always honors the EEPROM setting for this, which has 
> >>> been _on_ by default for all cards (AFAIK, that is).
> > 
> > It has _never ever_ worked on e1000 for as long as i have used e1000. If
> > it was intended to work, it must have been fixed in 2.6.16. So it is new
> > behavior.
> 
> Turns out that of the e1000 cards I can find around here that are plugged in 
> actually are 50-50 distributed on/off, so I was wrong about it being on by 
> default everywhere.
> 
> Looking back through the code I see no changes affecting flow control setup as 
> early as 2.6.12 ... There are some minor (new) HW changes but nothing that 
> should have boken fc.
> 

It could be something very basic. Since you have access to a variety of
hardware (and variety of kernels i take it), you can go by elimination
and find it.

cheers,
jamal

