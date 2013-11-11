From: Dave Taht <dave.taht@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 11:24:37 -0800
Message-ID: <CAA93jw4By5d2JRzMCooXM2nV2bdUfqwKCivP1ktb3wGa1wNkww@mail.gmail.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<21121.575.539384.948990@gargle.gargle.HOWL>
	<52810800.9020402@openwrt.org>
	<1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
	<CAA93jw7ciONyyUKNei5COVTA51tFWVBD4LQMp60wwxGGD=VBEQ@mail.gmail.com>
	<52812BF2.7090605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Sujith Manoharan <sujith@msujith.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Avery Pennarun <apenwarr@google.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:54403 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab3KKTYj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:24:39 -0500
Received: by mail-wi0-f169.google.com with SMTP id cb5so2779442wib.4
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 11:24:37 -0800 (PST)
In-Reply-To: <52812BF2.7090605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 11:11 AM, Ben Greear <greearb@candelatech.com> =
wrote:
> On 11/11/2013 10:31 AM, Dave Taht wrote:
>> Ah, this thread started with a huge regression in ath10k performance
>> with the new TSQ stuff, and isn't actually about a two line fix to t=
he
>> mv ethernet driver.
>>
>> http://comments.gmane.org/gmane.linux.network/290269
>>
>> I suddenly care a lot more. And I'll care a lot, lot, lot more, if
>> someone can post a rrul test for before and after the new fq schedul=
er
>> and tsq change on this driver on this hardware... What, if anything,
>> in terms of improvements or regressions, happened to multi-stream
>> throughput and latency?
>>
>> https://github.com/tohojo/netperf-wrapper
>
> Not directly related, but we have run some automated tests against
> an older buffer-bloat enabled AP (not ath10k hardware, don't know the
> exact details at the moment), and in general the performance
> is horrible compared to all of the other APs we test against.

I was not happy with the dlink product and the streamboost
implementation, if that is what it was.

> Our tests are concerned mostly with throughput.

:(

> For reference, here are some graphs with supplicant/hostapd
> running on higher-end x86-64 hardware and ath9k:
>
> http://www.candelatech.com/lf_wifi_examples.php
>
> We see somewhat similar results with most commercial APs, though
> often they max out at 128 or fewer stations instead of the several
> hundred we get on our own AP configs.
>
> We'll update to more recent buffer-bloat AP software and post some
> results when we get a chance.

Are you talking cerowrt (on the wndr3800) here? I am well aware that
it doesn't presently scale well with large numbers of clients, which
is awaiting the per-sta queue work. (most of the work to date has been
on the aqm-to-the-universe code)

This is the most recent stable firmware for that:

http://snapon.lab.bufferbloat.net/~cero2/cerowrt/wndr/3.10.17-6/

I just did 3.10.18 but haven't tested it.

Cero also runs HT20 by default, and there are numerous other things
that are configured more for "science" than throughput. Notably the
size of the aggregation queues is limited. But I'd LOVE a test through
your suite.

I note I'd also love to see TCP tests through your suite with the AP
configured thusly

(server) - (100ms delay box running a recent netem and a packet limit
of 100000+) - AP (w 1000 packets buffering/wo AQM, and with AQM) -
(wifi clients)

(and will gladly help set that up. Darn, I just drove past your offices=
)

>
> Thanks,
> Ben
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>



--=20
Dave T=E4ht
