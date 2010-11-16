From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Tue, 16 Nov 2010 17:25:06 +0900
Message-ID: <001501cb8567$c7a38820$66f8800a@maildom.okisemi.com>
References: <4CE0EFA7.9020007@dsn.okisemi.com>
	<4CE141EA.5070702@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Monday, November 15, 2010 11:21 PM, Wolfgang Grandegger wrote:

> 
> More comments to the lec handling below.
> 
> > + cf->data[6] = ioread32(&priv->regs->errc) & PCH_TEC;
> > + cf->data[7] = (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
> 
> Could be handle with just *one* register access.

I will modify.

>   if (reg_stat & PCH_BUS_OFF ||
>     (reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
> 
> Your lec handling is still not correc, 

I will modify like above.

> I believe. The driver needs to
> write PCH_LEC_ALL to the "stat" register once in the initialization code
This is NOT true.
I heard even if CAN driver detects PCH_LEC_ALL, the driver doesn't have to
write PCH_LEC_ALL to LEC.
"PCH_LEC_ALL" means there is no error event.
In case error is occurred, lec value is updated automatically.


> and then after each error observed (lec != PCH_LEC_ALL). I still do not
> find such code. Could you show us the output of
> 
>   "# candump any,0:0,#FFFFFFFF"
> 
> when yo send CAN messages *without* a cable connected?.


[root@localhost can-utils]# ./candump any,0:0,#FFFFFFFF
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 88 00   ERRORFRAME

......It seems the same line continues forever.

---
Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
