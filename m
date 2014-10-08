From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Wed, 8 Oct 2014 06:43:42 +0200
Message-ID: <20141008064342.5d4db175@ipc1.ka-ro>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	<20141007.131507.635415594538460008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
	Frank.Li@freescale.com, fabio.estevam@freescale.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141007.131507.635415594538460008.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller wrote:
> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> Date: Tue,  7 Oct 2014 15:19:37 +0200
>=20
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
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
>=20
> Why don't you just round up the length fec_enet_copybreak() uses when
> need_swap is true?  Then you will end up mimicking the original behav=
ior
> and not require this new helper function.
>=20
I wanted to eliminate the need to access the buffer twice (once for
copying and once for swapping).

> And in any case I agree with Sergei that if you do retain your approa=
ch,
> the new 'swap' argument to fec_enet_copybreak() should be a 'bool'.
>=20
Right.

> I'm really surprised there isn't a control register bit to adjust the
> endianness of the data DMA'd to/from the network.
>
This is a "feature" of the i.MX28.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
