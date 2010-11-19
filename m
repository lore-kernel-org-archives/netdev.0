From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Fri, 19 Nov 2010 16:36:58 +0900
Message-ID: <00bf01cb87bc$8ed6e300$66f8800a@maildom.okisemi.com>
References: <4CE0EFA7.9020007@dsn.okisemi.com>
	<4CE141EA.5070702@grandegger.com>
	<001501cb8567$c7a38820$66f8800a@maildom.okisemi.com>
	<4CE259FB.5090402@grandegger.com>
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

On Tuesday, November 16, 2010 7:16 PM, Wolfgang Grandegger wrote :

> > ......It seems the same line continues forever.
> 
> Yes, it will continue until you connect the cable, that's normal
> behavior. But that's not the full sequence. Could you please repeat the
> test as shown below:
> 
>   First start the following command in a *separate* session.
>   # candump any,0:0,#FFFFFFFF"
> 
>   Then setup and start the CAN controller:
>   # ip link set can0 up type can bitrate 125000
>   # cansend can0 123#deadbeef
> 

I show the result of the above command below,

[root@localhost can-utils]# candump any,0:0,#FFFFFFFF
  can0  20000020  [8] 00 00 00 00 00 00 08 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 10 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 18 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 20 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 28 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 30 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 38 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 40 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 48 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 50 00   ERRORFRAME
  can0  20000020  [8] 00 00 00 00 00 00 58 00   ERRORFRAME
  can0  20000024  [8] 00 00 00 00 00 00 60 00   ERRORFRAME
  can0  20000024  [8] 00 08 00 00 00 00 68 00   ERRORFRAME
  can0  20000024  [8] 00 08 00 00 00 00 70 00   ERRORFRAME
  can0  20000024  [8] 00 08 00 00 00 00 78 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME
  can0  20000024  [8] 00 28 00 00 00 00 80 00   ERRORFRAME

.....continue forever

------
Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
