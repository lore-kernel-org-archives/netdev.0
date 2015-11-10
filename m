From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 10 Nov 2015 13:51:20 -0800
Message-ID: <1447192280.17135.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
	 <20151110.150403.1195107307226924000.davem@davemloft.net>
	 <yw1xziylpoe8.fsf@unicorn.mansr.com>
	 <20151110.160615.1511568572619688788.davem@davemloft.net>
	 <yw1xvb99pn43.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xvb99pn43.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-10 at 21:21 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:

> Even ixgbe uses napi_complete() while netdevice.h says one should
> "consider using napi_complete_done() instead."  Did the author consid=
er
> it and decide not to, or has the driver simply not been updated?

napi_complete_done() is quite new, very few drivers use it.

It still requires a tuning (/sys/class/net/ethX/gro_flush_timeout)

>=20
> As for the napi_gro_receive() function, calling that instead of
> netif_receive_skb() is easy enough, or are there other things I shoul=
d
> be doing in addition?

Nothing comes to mind, if you already have a NAPI context,
napi_gro_receive() is the way to go...
