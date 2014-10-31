From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Fri, 31 Oct 2014 06:32:10 +0100
Message-ID: <20141031063210.69004315@ipc1.ka-ro>
References: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
	<20141029.153430.1036004676442879956.davem@davemloft.net>
	<20141030075104.05e44b43@ipc1.ka-ro>
	<20141030.121710.1524000348187962764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
	Frank.Li@freescale.com, fabio.estevam@freescale.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141030.121710.1524000348187962764.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller wrote:
> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> Date: Thu, 30 Oct 2014 07:51:04 +0100
>=20
> >> Also, I don't thnk your DIV_ROUND_UP() eliminate for the loop
> >> in swap_buffer() is valid.  The whole point is that the current
> >> code handles buffers which have a length which is not a multiple
> >> of 4 properly, after your change it will no longer do so.
> >>
> > Do you really think so?
>=20
> Yes, because you're rounding down so you'll miss the final
> partial word (if any).
>
Nope. DIV_ROUND_UP() would give '1' as upper bound for lengths from 1 t=
o
4, '2' for lengths from 5 to 8 and so on.

The loop with increment 4 and i < len does exactly the same.
Try it for yourself, if you don't believe it.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
