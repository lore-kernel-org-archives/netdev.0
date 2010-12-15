From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5 v2] ifb: add multiqueue support
Date: Wed, 15 Dec 2010 07:37:44 +0100
Message-ID: <1292395064.2377.1.camel@edumazet-laptop>
References: <1292340098-25537-1-git-send-email-xiaosuo@gmail.com>
	 <1292342358.5934.10.camel@edumazet-laptop>
	 <AANLkTikucnTO_+g2Fa=ZoMFQYbeiQSvqkJURF254So6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46568 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab0LOGhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 01:37:55 -0500
Received: by wyb28 with SMTP id 28so1171039wyb.19
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 22:37:54 -0800 (PST)
In-Reply-To: <AANLkTikucnTO_+g2Fa=ZoMFQYbeiQSvqkJURF254So6d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 08:20 +0800, Changli Gao a =C3=
=A9crit :
> On Tue, Dec 14, 2010 at 11:59 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >
> >
> > There is a problem here.
> >
> > You should sum in the loop rx_counters only, (the counters syncp
> > protected), and use dev_txq_stats_fold() to get the tx_counters fro=
m
> > core network.
>=20
> Hmm, in ifb, txq->tx_counters aren't used in ifb_xmit() but
> ri_tasklet(). IOW, rx and tx are reversed. Here I use txq->tx_counter=
s
> to reduce duplicate counters in ifb_q_private. Unless these variables
> might be accessed outside of ifb, I can use them freely? Thanks.
>=20

Yes, you are right, and the txq lock is not necessary to read their
values as well (I thought it was hold at write time)



