From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] gianfar: use netif_tx_queue_stopped
 instead of __netif_subqueue_stopped
Date: Sun, 18 Mar 2012 16:53:11 -0700
Message-ID: <1332114791.3597.6.camel@edumazet-laptop>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	 <1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
	 <1332106761-18293-5-git-send-email-paul.gortmaker@windriver.com>
	 <1332107741.9397.27.camel@edumazet-glaptop>
	 <CAP=VYLpzpbLVAJ6=L1jdoZWcyAWPPKGMFTKBVU=7=HR+qTxwwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:35522 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab2CRXxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 19:53:14 -0400
Received: by dajr28 with SMTP id r28so9018851daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 16:53:14 -0700 (PDT)
In-Reply-To: <CAP=VYLpzpbLVAJ6=L1jdoZWcyAWPPKGMFTKBVU=7=HR+qTxwwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 mars 2012 =C3=A0 19:24 -0400, Paul Gortmaker a =C3=A9cri=
t :
> On Sun, Mar 18, 2012 at 5:55 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > On Sun, 2012-03-18 at 17:39 -0400, Paul Gortmaker wrote:
> >> The __netif_subqueue_stopped() just does the following:
> >>
> >>         struct netdev_queue *txq =3D netdev_get_tx_queue(dev, queu=
e_index);
> >>         return netif_tx_queue_stopped(txq);
> >>
> >> and since we already have the txq in scope, we can just call that
> >> directly in this case.
> >>
> >> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> >> ---
> >>  drivers/net/ethernet/freescale/gianfar.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/ne=
t/ethernet/freescale/gianfar.c
> >> index 6e66cc3..d9428f0 100644
> >> --- a/drivers/net/ethernet/freescale/gianfar.c
> >> +++ b/drivers/net/ethernet/freescale/gianfar.c
> >> @@ -2565,7 +2565,7 @@ static int gfar_clean_tx_ring(struct gfar_pr=
iv_tx_q *tx_queue)
> >>       }
> >>
> >>       /* If we freed a buffer, we can restart transmission, if nec=
essary */
> >> -     if (__netif_subqueue_stopped(dev, tqi) && tx_queue->num_txbd=
free)
> >> +     if (netif_tx_queue_stopped(txq) && tx_queue->num_txbdfree)
> >>               netif_wake_subqueue(dev, tqi);
> >>
> >>       /* Update dirty indicators */
> >
> > Please change netif_wake_subqueue() as well ;)
>=20
> I looked at this earlier when I added patch #4 but I was concerned ab=
out
> the different semantics.
>=20
> The netif_wake_subqueue() just returns on a netpoll_trap but the othe=
r
> netif_tx_wake_queue() actually calls netif_tx_start_queue() for the s=
ame
> netpoll_trap instance.  Maybe that is OK, but I didn't want to be cha=
nging
> the behaviour of subtleties in stuff where I am clearly still learnin=
g.
>=20

I see... commit 7b3d3e4fc68 added a small difference here...
