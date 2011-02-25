From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 25 Feb 2011 12:40:40 +0100
Message-ID: <1298634040.2659.32.camel@edumazet-laptop>
References: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 17:57 +0800, Po-Yu Chuang a =C3=
=A9crit :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC's including
> Faraday A320 and Andes AG101.
>=20
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>

It seems fine to me, but I have somes questions=20

1) On V5, the receive function ftmac100_rx_packet() was able to process
several segments per skb. On V6 you process one frag only.

Isnt this NIC able to handle large MTU (say... 9000) ?

2) ftmac100_alloc_rx_page() is called and allocate a full page for a
rxdes.

128*4K -> 512 Kbytes of memory for RX ring

In V5, you were using half pages only, so 256 kbytes of memory.

If you look at other drivers (NIU, BENET), they are able to use exactly
128*2 kbytes (for a rxring of 128 slots, and 2Kbytes per slot)
