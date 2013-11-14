From: Dave Taht <dave.taht@gmail.com>
Subject: Re: TCP performance regression
Date: Thu, 14 Nov 2013 01:54:25 -0800
Message-ID: <CAA93jw7QiPJ2EzS4Eubb7JQtQNrqNdrZ13z+MBxD=kW2T6rXkg@mail.gmail.com>
References: <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com>
	<1384183799.16391.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com>
	<1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73FD@saturn3.aculab.com>
	<20131112074243.GA10318@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sujith Manoharan <sujith@msujith.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:60563 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab3KNJy0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:54:26 -0500
Received: by mail-wg0-f43.google.com with SMTP id n12so1650700wgh.22
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 01:54:25 -0800 (PST)
In-Reply-To: <20131112074243.GA10318@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 11:42 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Mon, Nov 11, 2013 at 04:35:30PM -0000, David Laight wrote:
>> > > It should be ok if the mac driver only gives the hardware a smal=
l
>> > > number of bytes/packets - or one appropriate for the link speed.
>> >
>> > There is some confusion here.
>> >
>> > mvneta has a TX ring buffer, which can hold up to 532 TX descripto=
rs.
>> >
>> > If this driver used skb_orphan(), a single TCP flow could use the =
whole
>> > TX ring.
>> >
>> > TCP Small Queue would only limit the number of skbs on Qdisc.
>> >
>> > Try then to send a ping message, it will have to wait a lot.
>>
>> 532 is a ridiculously large number especially for a slow interface.
>> At a guess you don't want more than 10-20ms of data in the tx ring.
>
> Well, it's not *that* large, 532 descriptors is 800 kB or 6.4 ms with
> 1500-bytes packets, and 273 microseconds for 64-byte packets. In fact
> it's not a slow interface, it's the systems it runs on which are
> generally not that fast. For example it is possible to saturate two
> gig ports at once on a single-core Armada370. But you need buffers
> large enough to compensate for the context switch time if you use
> multiple threads to send.

There is this terrible tendency to think that all interfaces run at
maximum rate, always. There has been an interesting trend towards
slower rates of late -Things like the pi and beaglebone black have
interfaces that run at 100Mbits (cheaper phy, less power), and thus
communication from a armada370 in this case, at line rate, would
induce up to 64ms of delay. A 10Mbit interface, 640ms. Many devices
that connect to the internet run at these lower speeds.

BQL can hold that down to something reasonable at a wide range of line
rates on ethernet.

In the context of 802.11 wireless, the rate problem is much, much
worse, going down to 1Mbit, and never getting as high as a gig, and
often massively extending things with exorbitant retries and
retransmits.

Although Eric fixed "the regression" on the new fq stuff vs a vs the
ath10k and ath9k, I would really have liked a set of benchmarks of the
ath10k and ath9k device and driver at realistic rates like MCS1 and
MCS4, to make more clear the problems those devices have at real
world, rather than lab, transmission rates.


>
> Regards,
> Willy
>



--=20
Dave T=E4ht

=46ixing bufferbloat with cerowrt: http://www.teklibre.com/cerowrt/subs=
cribe.html
