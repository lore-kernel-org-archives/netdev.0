From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 14:21:18 -0700
Message-ID: <ED315045-4A5D-4ECA-99C8-06B4714D8FA0@earthlink.net>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com> <1277716394.4235.235.camel@edumazet-laptop> <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net> <1277719251.4235.306.camel@edumazet-laptop> <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com> <1277723370.4235.388.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Courtier-Dutton <james.dutton@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:50524 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755219Ab0F1VV2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 17:21:28 -0400
In-Reply-To: <1277723370.4235.388.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 28, 2010, at 4:09 AM, Eric Dumazet wrote:

> Le lundi 28 juin 2010 =E0 11:17 +0100, James Courtier-Dutton a =E9cri=
t :
>> On 28 June 2010 11:00, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>=20
>>> Problem is we receive a spike of RX network frames (possibly UDP or=
 some
>>> other RX only trafic), and chip raises an RX fifo overflow _error_
>>> indication.
>>>=20

IMO, spikes are a normal behaviour.

>>=20
>> The cause of the RX overflow is in my case is TCP.
>> It is reproducible in mythtv.
>> While watching LiveTV, press "s" for the program guide.
>> The program guide is implemented into mythtv by a SQL query that
>> results in a large response.
>> The kernel is probably not servicing the RX FIFO quickly enough due =
to
>> it being busy doing something else. In this case, probably a video
>> mode switch.
>>=20
>=20
> Thats strange, b44 has a big RX ring... and tcp sender should wait fo=
r
> ACK...
>=20

Slow start, etc SHOULD/CAN  double the number of in-flight segments in =
each
next round-trip, placing them back to back.

IMO,  a stress test, would be a large number/wirespeed set of pings?

>>> Some hardware are buggy enough that such error indication is fatal =
and
>>> _require_ hardware reset. Thats life. I suspect b44 driver doing a =
full
>>> reset is not a random guess from driver author, but to avoid a comp=
lete
>>> NIC lockup.
>>>=20
>>=20
>> Interesting, which hardware, apart from the b44, is it that "require=
s"
>> a hardware reset after a RX FIFO overflow.
>=20
> Just take a look at some net drivers and you'll see some of them have
> this requirement.
>=20
> rtl8169_rx_interrupt()
> ...
> 	if (status & RxFOVF) {
> 		rtl8169_schedule_work(dev, rtl8169_reset_task);
> 		dev->stats.rx_fifo_errors++;
> 	}
>=20
>=20
>=20
>=20


If they can reset in say X frame loss units, then why not reset if
X is an acceptable number?

And a hammer may fix the dent, while I may be more
interested in preventing the dent in the first place.

Mitchell Erblich





