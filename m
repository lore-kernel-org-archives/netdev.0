From: David Miller <davem@davemloft.net>
Subject: Re: net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Tue, 04 Nov 2014 11:28:58 -0500 (EST)
Message-ID: <20141104.112858.356827532569349127.davem@davemloft.net>
References: <20141030.121710.1524000348187962764.davem@davemloft.net>
	<20141031063210.69004315@ipc1.ka-ro>
	<20141104112912.2be8bf1a@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rmk+kernel@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141104112912.2be8bf1a@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Tue, 4 Nov 2014 11:29:12 +0100

> Hi David,
>=20
> Lothar Wa=DFmann wrote:
>> David Miller wrote:
>> > From: Lothar Wa=DFmann <LW@KARO-electronics.de>
>> > Date: Thu, 30 Oct 2014 07:51:04 +0100
>> >=20
>> > >> Also, I don't thnk your DIV_ROUND_UP() eliminate for the loop
>> > >> in swap_buffer() is valid.  The whole point is that the current
>> > >> code handles buffers which have a length which is not a multipl=
e
>> > >> of 4 properly, after your change it will no longer do so.
>> > >>
>> > > Do you really think so?
>> >=20
>> > Yes, because you're rounding down so you'll miss the final
>> > partial word (if any).
>> >
>> Nope. DIV_ROUND_UP() would give '1' as upper bound for lengths from =
1 to
>> 4, '2' for lengths from 5 to 8 and so on.
>>=20
>> The loop with increment 4 and i < len does exactly the same.
>> Try it for yourself, if you don't believe it.
>>=20
>>=20
> Do you still think, the loop without DIV_ROUND_UP() is incorrect,
> or can this patch be applied?

I haven't had the time to fully re-look into the details, I'm busy
with many other things at the moment.

But looking at DIV_ROUND_UP() macro it rounds up.  It gives an
upper bound of 4 for any value 1 to 4.  Unlike what you claim.

Because it goes "(n + (d - 1)) / d"

Which for 'd' of 4 gives:

1 --> 4
2 --> 4
3 --> 4
4 --> 4
