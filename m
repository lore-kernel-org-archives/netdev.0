From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Wed, 8 Oct 2014 06:59:21 +0200
Message-ID: <20141008065921.068385a6@ipc1.ka-ro>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	<063D6719AE5E284EB5DD2968C1650D6D174C6025@AcuExch.aculab.com>
	<20141007161702.7cd1e800@ipc1.ka-ro>
	<063D6719AE5E284EB5DD2968C1650D6D174C60B1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:51594 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbaJHE70 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 00:59:26 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C60B1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Laight wrote:
> From: Lothar
> > David Laight wrote:
> > > From: Lothar Wa=C3=9Fmann
> > > > commit 1b7bde6d659d ("net: fec: implement rx_copybreak to impro=
ve rx performance")
> > > > introduced a regression for i.MX28. The swap_buffer() function =
doing
> > > > the endian conversion of the received data on i.MX28 may access=
 memory
> > > > beyond the actual packet size in the DMA buffer. fec_enet_copyb=
reak()
> > > > does not copy those bytes, so that the last bytes of a packet m=
ay be
> > > > filled with invalid data after swapping.
> > > > This will likely lead to checksum errors on received packets.
> > > > E.g. when trying to mount an NFS rootfs:
> > > > UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:446=
62 ulen 36
> > > >
> > > > Do the byte swapping and copying to the new skb in one go if
> > > > necessary.
> > >
> > > ISTM that if you need to do the 'swap' you should copy the data r=
egardless
> > > of the length.
> > >
> > The swap function has to look at at most 3 bytes beyond the actual
> > packet length. That is what the original swap_buffer() function doe=
s and
> > what the new function swap_buffer2(), that does the endian swapping
> > while copying to the new buffer, also does.
>=20
> I understood the bug.
>=20
> The point I was making is that if you have to do a read-write of the =
received
> data (to byteswap it) then you might as well always copy it into a ne=
w skb that
> is just big enough for the actual receive frame.
>=20
I wanted to use the least intrusive solution.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
