From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 07 Oct 2014 13:15:07 -0400 (EDT)
Message-ID: <20141007.131507.635415594538460008.davem@davemloft.net>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
	Frank.Li@freescale.com, fabio.estevam@freescale.com,
	linux-kernel@vger.kernel.org
To: LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Tue,  7 Oct 2014 15:19:37 +0200

> commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx =
performance")
> introduced a regression for i.MX28. The swap_buffer() function doing
> the endian conversion of the received data on i.MX28 may access memor=
y
> beyond the actual packet size in the DMA buffer. fec_enet_copybreak()
> does not copy those bytes, so that the last bytes of a packet may be
> filled with invalid data after swapping.
> This will likely lead to checksum errors on received packets.
> E.g. when trying to mount an NFS rootfs:
> UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 ule=
n 36
>=20
> Do the byte swapping and copying to the new skb in one go if
> necessary.
>=20
> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>

Why don't you just round up the length fec_enet_copybreak() uses when
need_swap is true?  Then you will end up mimicking the original behavio=
r
and not require this new helper function.

And in any case I agree with Sergei that if you do retain your approach=
,
the new 'swap' argument to fec_enet_copybreak() should be a 'bool'.

I'm really surprised there isn't a control register bit to adjust the
endianness of the data DMA'd to/from the network.
