From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 7 Oct 2014 16:17:02 +0200
Message-ID: <20141007161702.7cd1e800@ipc1.ka-ro>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	<063D6719AE5E284EB5DD2968C1650D6D174C6025@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	"Fabio Estevam" <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C6025@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Laight wrote:
> From: Lothar Wa=C3=9Fmann
> > commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve r=
x performance")
> > introduced a regression for i.MX28. The swap_buffer() function doin=
g
> > the endian conversion of the received data on i.MX28 may access mem=
ory
> > beyond the actual packet size in the DMA buffer. fec_enet_copybreak=
()
> > does not copy those bytes, so that the last bytes of a packet may b=
e
> > filled with invalid data after swapping.
> > This will likely lead to checksum errors on received packets.
> > E.g. when trying to mount an NFS rootfs:
> > UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 u=
len 36
> >=20
> > Do the byte swapping and copying to the new skb in one go if
> > necessary.
>=20
> ISTM that if you need to do the 'swap' you should copy the data regar=
dless
> of the length.
>=20
The swap function has to look at at most 3 bytes beyond the actual
packet length. That is what the original swap_buffer() function does an=
d
what the new function swap_buffer2(), that does the endian swapping
while copying to the new buffer, also does.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
