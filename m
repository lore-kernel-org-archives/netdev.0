From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Tue, 9 Nov 2010 21:26:41 +0900
Message-ID: <00fd01cb8009$5efc5fd0$66f8800a@maildom.okisemi.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de> <4CCAFA68.2030903@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Oliver Hartkopp" <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry, for late response.
On Saturday, October 30, 2010 1:46 AM,  Oliver Hartkopp wrote:

> 
> It's just a question if the driver for an Intel Chipset should/could ignore
> the endian problematic.
> 
> If this is intended the driver should only appear in Kconfig depending on X86
> or little endian systems.

This driver is for only x86 processor.
I have no intention to support processor except x86.

> 
> Besides this remark, the struct pch_can_regs could also be defined in a way
> that every single CAN payload data byte could be accessed directly to allow
> e.g. this code in pch_can_rx_normal():
> 
> cf->data[0] = ioread8(&priv->regs->if1_data0);
> cf->data[1] = ioread8(&priv->regs->if1_data1);
> cf->data[2] = ioread8(&priv->regs->if1_data2);
> (..)
> cf->data[6] = ioread8(&priv->regs->if1_data6);
> cf->data[7] = ioread8(&priv->regs->if1_data7);
> 
> This is easy to understand and additionally endian aware.

I agree. Thease codes are very simple.
I will modify like above.

> 
> In opposite to this:
> 
> + if (cf->can_dlc > 2) {
> + u32 data1 = *((u16 *)&cf->data[2]);
> + iowrite32(data1, &priv->regs->if2_dataa2);
> + }
> 
> Which puts a little? endian u16 into the big endian register layout.
> Sorry i'm just getting curious on this register access implementation.

I think cf->data is like below
MSB----------LSB
D3-D2-D1-D0
D7-D6-D5-D4

*((u16 *)&cf->data[2]) means "D3-D2".
This order coprresponds to register order.
data register is like below
MSB----------LSB
**-**-D3-D2

** means reserved area.

Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
