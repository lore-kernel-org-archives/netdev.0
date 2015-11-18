From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 18 Nov 2015 17:38:02 +0100
Message-ID: <CAAP7ucKpH5LTV1pw-JBJ=mD4_QFBwKYU9tLANkM4s40c+Oc0Hg@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511041633.33504.marex@denx.de>
	<CAAP7ucJZxqUdA-B4m=u-+-BGkydYaSdnutiPf4ik36EcfjiUzQ@mail.gmail.com>
	<201511101715.39253.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34911 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbbKRQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 11:38:04 -0500
Received: by obbnk6 with SMTP id nk6so37587560obb.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 08:38:03 -0800 (PST)
In-Reply-To: <201511101715.39253.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 5:15 PM, Marek Vasut <marex@denx.de> wrote:
>> >> >>> > About the parity -- can we add some flag into the datagram to
>> >> >>> > indicate we want hardware to calculate the parity for that
>> >> >>> > particular datagram for us? And we'd also need to indicate what
>> >> >>> > type of parity. I dunno if this is worth the hassle.
>> >> >>>
>> >> >>> This  is HW configuration property, it does not belong to  datagram.
>> >> >>> Also for TX channels,  parity could  be  two  kinds:  odd and even,
>> >> >>> for RX it is only on/off.
>> >> >>
>> >> >> There are datagrams which do contain parity and ones which do not
>> >> >> contain it, correct ? Thus, it's a property of that particular
>> >> >> datagram.
>> >>
>> >> All ARINC words have bit #31 as parity bit; whether it's used or not
>> >> depends on the setup as Andrey says below.
>> >
>> > Can bit 31 be ever used for DATA instead of parity ? Or is this just me
>> > not understanding the parlance of the specification, where "DATA"
>> > actually means "DATA with parity" ?
>>
>> Well, as far as I know bit 31 is always parity bit, never used for
>> actual data contents. Which is the spec section that got you confused?
>> Maybe I'm the one which didn't read it well?
>
> Sorry for being so late into the discussion.
>
> I got confused by hi-3585_v-rev-l.pdf page 7 right, CR4 lets you treat bit
> 32 as either data or parity. But I guess this is not the general case.
>
> So I wonder, does it make sense to treat the P bit as data always and do
> parity in software or not ?

I don't have an strong opinion on this, truth be told. It really
depends on whether we can tell the HW "go compute the parity
yourself". If we can ask for that, maybe we should allow configuring
that in the API with some flag. But anyway, treating P as data (i.e.
software should set parity bit to whatever is needed) is the most
generic thing you could do for a start, that shouldn't be wrong.

-- 
Aleksander
https://aleksander.es
