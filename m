From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 12 Oct 2010 09:42:52 +0200
Message-ID: <4CB4117C.4070207@grandegger.com>
References: <002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>	<20101005.114506.184852374.davem@davemloft.net>	<000b01cb6503$962bc7f0$66f8800a@maildom.okisemi.com>	<20101005.200904.71120150.davem@davemloft.net>	<4CAC3D94.9010408@grandegger.com>
	<000c01cb69dc$5d2aaab0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000c01cb69dc$5d2aaab0$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

Hi Ohtake,

On 10/12/2010 09:09 AM, Masayuki Ohtake wrote:
> Hi Wolfgang,
> 
> We have implemented our CAN driver with FIFO mode, and
> We are testing our CAN driver with FIFO mode.
> However, we have found Our CAN hardware spec is different from our anticipated.
> Our CAN HW FIFO is not common FIFO.
> Using  FIFO mode, there is possibility received packets are out-of-order.
> 
> e.g.
> Recv packet-A from NW and set to FIFO.
>   |A|
> 
> Recv packet-B from NW and set to FIFO.
>   |A|B|
> 
> Recv packet-C is about to set to FIFO
>   |A|B|(C)|
> 
> Userspace Copies A from Driver

OK, let's say the CPU or software starts processing the message FIFO.

> Userspace Copies B from Driver
>   |   |   |(C)|
> 
> packet-C set to FIFO (C is not head.)
> Recv packet-D from NW(Next packet is set to head)
>   |D|   |C|
> 
> Userspace Copies D from Driver

The software could continues searching the FIFO for valid messages. Then
it would find C first.

> Userspace Copies C from Driver
> Userspace raceived packet order is like below
> A-B-D-C

I'm still optimistic that it could be handled properly by software, it
might be tricky though.

> So, I think normal-mode is better than FIFO-mode.

To be clear. Out-of-order reception is not allowed!

> I will revert like the following spec.
>   Rx 1 Message Object
>   Tx 1 Message Object
> 
> Could you agree the above ?

See above. I agree if the software cannot assure in-order reception. But
it's not yet obvious to me that it cannot be achieved. I will have a
closer look to the manual. Just one RX message object without any
further buffering is really bad as message losses are likely to happen.

Wolfgang.
