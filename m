From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 12 Oct 2010 16:09:04 +0900
Message-ID: <000c01cb69dc$5d2aaab0$66f8800a@maildom.okisemi.com>
References: <002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>	<20101005.114506.184852374.davem@davemloft.net>	<000b01cb6503$962bc7f0$66f8800a@maildom.okisemi.com>
	<20101005.200904.71120150.davem@davemloft.net>
	<4CAC3D94.9010408@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Hi Wolfgang,

We have implemented our CAN driver with FIFO mode, and
We are testing our CAN driver with FIFO mode.
However, we have found Our CAN hardware spec is different from our anticipated.
Our CAN HW FIFO is not common FIFO.
Using  FIFO mode, there is possibility received packets are out-of-order.

e.g.
Recv packet-A from NW and set to FIFO.
  |A|

Recv packet-B from NW and set to FIFO.
  |A|B|

Recv packet-C is about to set to FIFO
  |A|B|(C)|

Userspace Copies A from Driver
Userspace Copies B from Driver
  |   |   |(C)|

packet-C set to FIFO (C is not head.)
Recv packet-D from NW(Next packet is set to head)
  |D|   |C|

Userspace Copies D from Driver
Userspace Copies C from Driver
Userspace raceived packet order is like below
A-B-D-C

So, I think normal-mode is better than FIFO-mode.

I will revert like the following spec.
  Rx 1 Message Object
  Tx 1 Message Object

Could you agree the above ?

Thanks, Ohtake(OKISemi)
----- Original Message ----- 
From: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>;
<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>;
<mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; <chripell-VaTbYqLCNhc@public.gmane.org>; <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>;
<kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sent: Wednesday, October 06, 2010 6:12 PM
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35


> On 10/06/2010 05:09 AM, David Miller wrote:
> > From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> > Date: Wed, 6 Oct 2010 12:07:15 +0900
> >
> >> Does your mail mean, for accepting upstream, NAPI is essential for
> >> CAN driver ?
> >
> > It is up to the CAN maintainers :-)
>
> Well, our SJA1000 reference driver does still not use NAPI. But NAPI is
> for CAN especially useful to avoid the infamous *bus error irq
> flooding*, which may hang low end systems if the interrupts are handled
> in the IRQ context. Ohtake, if your system can handle well such CAN bus
> error irq storms at 1MB/s, then NAPI is *not* a must to have. Anyway, as
> you are at it, I also suggest to use NAPI right from the beginning.
>
> Wolfgang.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
