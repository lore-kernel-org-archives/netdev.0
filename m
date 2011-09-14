From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
Date: Wed, 14 Sep 2011 10:57:19 -0400
Message-ID: <20110914145719.GB3866@hmsreliant.think-freely.org>
References: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
 <1316006922.2361.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pekka Riikonen <priikone@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58340 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513Ab1INO5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 10:57:31 -0400
Content-Disposition: inline
In-Reply-To: <1316006922.2361.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2011 at 03:28:41PM +0200, Eric Dumazet wrote:
> Le mercredi 14 septembre 2011 =E0 09:05 -0400, Neil Horman a =E9crit =
:
> > d88733150 introduced the IFF_SKB_TX_SHARING flag, which I unilatera=
lly set in
> > ether_setup.  In doing this I didn't realize that other flags (such=
 as
> > IFF_XMIT_DST_RELEASE) might be set prior to calling the ether_setup=
 routine.
> > This patch changes ether_setup to or in SKB_TX_SHARING so as not to
> > inadvertently clear other existing flags.  Thanks to Pekka Riikonen=
 for pointing
> > out my error
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Pekka Riikonen <priikone@iki.fi>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  net/ethernet/eth.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> > index 27997d3..a246836 100644
> > --- a/net/ethernet/eth.c
> > +++ b/net/ethernet/eth.c
> > @@ -340,7 +340,7 @@ void ether_setup(struct net_device *dev)
> >  	dev->addr_len		=3D ETH_ALEN;
> >  	dev->tx_queue_len	=3D 1000;	/* Ethernet wants good queues */
> >  	dev->flags		=3D IFF_BROADCAST|IFF_MULTICAST;
> > -	dev->priv_flags		=3D IFF_TX_SKB_SHARING;
> > +	dev->priv_flags		|=3D IFF_TX_SKB_SHARING;
> > =20
> >  	memset(dev->broadcast, 0xFF, ETH_ALEN);
> > =20
>=20
> I CC Pekka Riikonen <priikone@iki.fi>, not sure if he is netdev
> subscribded.
>=20
Thank you Eric, I didn't check and assumed my config CC'ed Reported-by:=
 emails
Neil

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
