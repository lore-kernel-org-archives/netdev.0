From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add IRQF_SAMPLE_RANDOM Flag to forcedeth
Date: Sun, 10 Oct 2010 10:57:54 +0200
Message-ID: <1286701074.2692.215.camel@edumazet-laptop>
References: <4CB0FEA6.3030206@netscape.net>
	 <20101010010924.GB15074@solarflare.com>
	 <20101009.201501.214209347.davem@davemloft.net>
	 <4CB13195.2070007@netscape.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Patrick Simmons <linuxrocks123@netscape.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60849 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab0JJI6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 04:58:03 -0400
Received: by wyb28 with SMTP id 28so2212503wyb.19
        for <netdev@vger.kernel.org>; Sun, 10 Oct 2010 01:58:02 -0700 (PDT)
In-Reply-To: <4CB13195.2070007@netscape.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 09 octobre 2010 =C3=A0 21:23 -0600, Patrick Simmons a =C3=A9c=
rit :
> On 10/09/10 21:15, David Miller wrote:
> > From: Ben Hutchings<bhutchings@solarflare.com>
> > Date: Sun, 10 Oct 2010 02:09:24 +0100
> >
> >> Patrick Simmons wrote:
> >>> This patch adds the IRQF_SAMPLE_RANDOM flag to the forcedeth driv=
er,
> >>> allowing the interrupt timing for forcedeth to be used for entrop=
y
> >>> generation.  This should help /dev/random generate more secure ra=
ndom
> >>> numbers on machines using this driver.
> >> [...]
> >>
> >> We don't enable this for network drivers any more because:
> >>
> >> 1. At high packet rates, interrupt moderation makes interrupts ver=
y
> >> regular.
> >> 2. At low packet rates, a malicious sender can control the interru=
pt
> >> timing.
> >
> > Agreed on all counts, I'm not applying this patch.
>=20
> It's enabled for other network drivers, which is where I got the idea=
=20
> from.  Has anyone actually done an experiment to see whether these tw=
o=20
> concerns are valid?

Several attemps in the past tried to go into one direction or another

(Add the flag to some driver, then remove it from others)

Please read commit 9d9b8fb0e5ebf4b0398e579
http://lkml.org/lkml/2009/4/6/283

A third reason not adding is : At moderate packet rates, _no_ entropy i=
s
feeded at all because add_interrupt_randomness()/add_timer_randomness i=
s
_very_ conservative, with first, second-order and third-order estimates=
=2E

credit_entropy_bits() is called with 0 bit

Adding this stuff has a high cost, I can see it in profiles on machines
with tg3 nics. I often remove the IRQF_SAMPLE_RANDOM flag localy.



