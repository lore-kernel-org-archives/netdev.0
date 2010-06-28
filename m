From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 13:09:30 +0200
Message-ID: <1277723370.4235.388.camel@edumazet-laptop>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	 <1277716394.4235.235.camel@edumazet-laptop>
	 <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	 <1277719251.4235.306.camel@edumazet-laptop>
	 <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mitchell Erblich <erblichs@earthlink.net>, netdev@vger.kernel.org
To: James Courtier-Dutton <james.dutton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55228 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab0F1LJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 07:09:38 -0400
Received: by wyb38 with SMTP id 38so1664330wyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 04:09:36 -0700 (PDT)
In-Reply-To: <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 11:17 +0100, James Courtier-Dutton a =C3=A9=
crit :
> On 28 June 2010 11:00, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Problem is we receive a spike of RX network frames (possibly UDP or=
 some
> > other RX only trafic), and chip raises an RX fifo overflow _error_
> > indication.
> >
>=20
> The cause of the RX overflow is in my case is TCP.
> It is reproducible in mythtv.
> While watching LiveTV, press "s" for the program guide.
> The program guide is implemented into mythtv by a SQL query that
> results in a large response.
> The kernel is probably not servicing the RX FIFO quickly enough due t=
o
> it being busy doing something else. In this case, probably a video
> mode switch.
>=20

Thats strange, b44 has a big RX ring... and tcp sender should wait for
ACK...

> > Some hardware are buggy enough that such error indication is fatal =
and
> > _require_ hardware reset. Thats life. I suspect b44 driver doing a =
full
> > reset is not a random guess from driver author, but to avoid a comp=
lete
> > NIC lockup.
> >
>=20
> Interesting, which hardware, apart from the b44, is it that "requires=
"
> a hardware reset after a RX FIFO overflow.

Just take a look at some net drivers and you'll see some of them have
this requirement.

rtl8169_rx_interrupt()
=2E..
	if (status & RxFOVF) {
		rtl8169_schedule_work(dev, rtl8169_reset_task);
		dev->stats.rx_fifo_errors++;
	}




