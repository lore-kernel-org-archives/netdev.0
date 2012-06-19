From: =?UTF-8?B?QW7DrWJhbCBBbG1laWRhIFBpbnRv?= <anibal.pinto@efacec.com>
Subject: Re: [RFC] micrel KSZ8041 disable auto negotiation with fiber
Date: Tue, 19 Jun 2012 18:53:29 +0100
Message-ID: <4FE0BC99.2030101@efacec.com>
References: <4FE090A7.801@efacec.com> <1340125709.2692.23.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.efacec.com ([213.58.230.66]:41706 "HELO mail3.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752561Ab2FSSGQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 14:06:16 -0400
In-Reply-To: <1340125709.2692.23.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Ter 19 Jun 2012 18:08:29 WEST, Ben Hutchings escreveu:
> On Tue, 2012-06-19 at 15:45 +0100, An=C3=ADbal Almeida Pinto wrote:
>> Hi,
>>
>> I am working on a custom board based on a OMAP L138 with a KSZ8041TL=
-FTL
>> phy that have fibber and copper support.
>>
>> When using with fibber the board can't connect to a switch, only aft=
er
>> exec :
>>
>> 	ethtool -s eth1 speed 100 duplex full autoneg off
>>
>> the phy get link and start working.
>>
>> On some switches it appears that autoneg don't work well with fibber=
,
>> ethtool reports that its at 10MB/s after exec
>>
>> 	ethtool -s eth1 autoneg on
>
> I'm not aware of any specification for autoneg over fibre, so I imagi=
ne
> the PHY is being programmed with an invalid configuration and sending
> weird signals.
>
>> The auto negotiation bit on phy register is disable on start when us=
ing
>> the fibber but Linux don't appear to look at it.
>>
>> Found a thread [1] that solve the problem but don't appear to be ful=
ly
>> accepted.
>>
>> The problem is modifying the phy code without interfere with ethtool=
 use.
>>
>> Any official/accepted solution to this problem ?
>
> The net driver or PHY driver needs to disable autoneg by default when
> connected to fibre, and reject attempts to turn it on.
>
> As for *how* the driver is supposed to know whether that's the case, =
I
> have no idea...

On this chip you have a pin where you can specify if is fibber or=20
copper, at power up it cleat/set the bit of auto negotiation.

The driver can save the bit state after phy power up or reset, and with=
=20
that validate if is copper or fibber.

In the case of fibber shouldn't allow change the auto negotiation.

>
>> [1] - http://marc.info/?l=3Dlinuxppc-embedded&m=3D131107263711714
>
> ...which seems to be where the previous discussion ended.
>
> Ben.
>
