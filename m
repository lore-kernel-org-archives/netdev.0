From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 10:18:09 +0200
Message-ID: <1274257089.2766.7.camel@edumazet-laptop>
References: <20100519075721.GA23926@gondor.apana.org.au>
	 <1274256582.2766.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:52526 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab0ESISM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:18:12 -0400
Received: by wwb22 with SMTP id 22so380537wwb.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 01:18:11 -0700 (PDT)
In-Reply-To: <1274256582.2766.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 10:09 +0200, Eric Dumazet a =C3=A9crit :

> Another concern I have is about RPS.
>=20
> netif_receive_skb() must be called from process_backlog() context, or
> there is no guarantee the IPI will be sent if this skb is enqueued fo=
r
> another cpu.

Hmm, I just checked again, and this is wrong.

In case we enqueue skb on a remote cpu backlog, we also
do __raise_softirq_irqoff(NET_RX_SOFTIRQ); so the IPI will be done
later.



