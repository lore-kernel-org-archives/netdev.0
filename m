From: David Miller <davem@davemloft.net>
Subject: Re: net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Wed, 29 Oct 2014 15:34:30 -0400 (EDT)
Message-ID: <20141029.153430.1036004676442879956.davem@davemloft.net>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
	<1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
	Frank.Li@freescale.com, fabio.estevam@freescale.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Tue, 28 Oct 2014 14:22:55 +0100

> Changes wrt. v1:
> - added some cleanup patches
> - simplify handling of 'quirks' flags as suggested by Russell King.
> - remove DIV_ROUND_UP() from byte swapping loop as suggested by
>   Eric Dumazet
>=20
> Changes wrt. v2:
> - rebased against next-20141028
> - added some more cleanups in fec.h
> - removed unused return value from swap_buffer()
> - fixed messed swab32s() call in swap_buffer2()
> - fixed messed up setup of fep->quirks
>=20

It is not appropriate to mix cleanups and bonafide bug fixes.

I want to see only bug fixes targetted at 'net'.  You can later
submit the cleanups to 'net-next'.

Also, I don't thnk your DIV_ROUND_UP() eliminate for the loop
in swap_buffer() is valid.  The whole point is that the current
code handles buffers which have a length which is not a multiple
of 4 properly, after your change it will no longer do so.
