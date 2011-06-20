From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 19:19:10 +0200
Message-ID: <1308590350.2658.6.camel@edumazet-laptop>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
	 <20110620163316.GC994@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40380 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585Ab1FTRTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 13:19:13 -0400
Received: by wwe5 with SMTP id 5so2774109wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 10:19:12 -0700 (PDT)
In-Reply-To: <20110620163316.GC994@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 18:33 +0200, Lennert Buytenhek a =C3=A9cri=
t :
> On Mon, Jun 20, 2011 at 09:48:07AM +0200, Richard Cochran wrote:
>=20
> > Because the socket buffer is freed in the completion interrupt, it
> > is not safe to access it after submitting it to the hardware.
>=20
> Maybe I'm missing something here, but mv643xx_eth TX reclaim is done
> from NAPI poll, under __netif_tx_lock(), while mv643xx_eth_xmit() als=
o
> runs under __netif_tx_lock().

See my previous answer. Its true this driver _currently_ holds tx queue
lock in its TX completion. But that might/should change.

Goal is to make tx completion not use tx queue lock in fast path, like
its done in tg3, bnx2, bnx2x ... and other recent drivers.

Its obviously correct to move skb->len access in start_xmit() before
starting the IO, even if not a bug fix, it makes all drivers behave the
same : When reviewing them, its easier not to worry about these possibl=
e
use after free.



