From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Wed, 28 Dec 2011 20:16:06 +0100
Message-ID: <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
References: <1325092423.2327.70.camel@deadeye>
	<CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
	<20111228101710.51c4893f@nehalam.linuxnetplumber.net>
	<20111228.133450.479385013770977594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rl@hellgate.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33216 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab1L1TQH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:16:07 -0500
In-Reply-To: <20111228.133450.479385013770977594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/28 David Miller <davem@davemloft.net>:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 28 Dec 2011 10:17:10 -0800
>
>> Looks like the hardware isn't really disabling interrupts correctly =
to support
>> NAPI. NAPI is supposed to be friendly and under load the work should=
 move to
>> ksoftirqd. I suspect the IRQ management in this driver is borked.
>> There is some stupid spin loops in the IRQ handler that happen when =
looking for
>> Tx IRQ. I would run with debug set =A0and see if this is triggering.
>
> This could be simply a side effect of the fact that via-rhine only do=
es
> RX work in it's NAPI handler.
>
> If all the work (or at least both TX and RX) were moved into the NAPI
> handler, it'd probably be easier to properly shut off all IRQs during
> NAPI processing, and thus avoid the high CPU load in the IRQ handler
> being seen here.
>
> This "shut off only some interrupts" scheme is just asking for troubl=
e.

I agree, it's an ugly hack :)

Is there some way I can help with this, without having to touch the
code? (C isn't my strong language, especially not kernel mode code) :)

/Bjarke

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
