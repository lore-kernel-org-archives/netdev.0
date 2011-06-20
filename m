From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 19:21:45 +0200
Message-ID: <1308590505.2658.8.camel@edumazet-laptop>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
	 <20110620163316.GC994@wantstofly.org>
	 <1308590350.2658.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63882 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125Ab1FTRVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 13:21:48 -0400
Received: by wyb38 with SMTP id 38so1822418wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 10:21:47 -0700 (PDT)
In-Reply-To: <1308590350.2658.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 19:19 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 20 juin 2011 =C3=A0 18:33 +0200, Lennert Buytenhek a =C3=A9c=
rit :
> > On Mon, Jun 20, 2011 at 09:48:07AM +0200, Richard Cochran wrote:
> >=20
> > > Because the socket buffer is freed in the completion interrupt, i=
t
> > > is not safe to access it after submitting it to the hardware.
> >=20
> > Maybe I'm missing something here, but mv643xx_eth TX reclaim is don=
e
> > from NAPI poll, under __netif_tx_lock(), while mv643xx_eth_xmit() a=
lso
> > runs under __netif_tx_lock().
>=20
> See my previous answer. Its true this driver _currently_ holds tx que=
ue
> lock in its TX completion. But that might/should change.
>=20
> Goal is to make tx completion not use tx queue lock in fast path, lik=
e
> its done in tg3, bnx2, bnx2x ... and other recent drivers.
>=20
> Its obviously correct to move skb->len access in start_xmit() before
> starting the IO, even if not a bug fix, it makes all drivers behave t=
he
> same : When reviewing them, its easier not to worry about these possi=
ble
> use after free.
>=20
>=20

One random example found in drivers/staging/hv/netvsc_drv.c

Is the "net->stats.tx_bytes +=3D skb->len;" found in line 188 is correc=
t ?

Who knows ?

I believe its not correct ;)



