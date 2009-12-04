From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Fri, 4 Dec 2009 07:48:33 +0000
Message-ID: <20091204074833.GA6478@ff.dom.local>
References: <4B17EFE3.4080301@gmail.com> <20091203202937.GA11436@ami.dom.local> <4B182DC6.5030800@gmail.com> <20091203.133108.254093305.davem@davemloft.net> <4B1832DD.1070805@gmail.com> <20091203224742.GA16646@ami.dom.local> <4B18440A.2080507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:41057 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbZLDHsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 02:48:33 -0500
Received: by bwz27 with SMTP id 27so1740269bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 23:48:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B18440A.2080507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 12:04:42AM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Thu, Dec 03, 2009 at 10:51:25PM +0100, Eric Dumazet wrote:
> >> David Miller a =E9crit :
> >>> From: Eric Dumazet <eric.dumazet@gmail.com>
> >>> Date: Thu, 03 Dec 2009 22:29:42 +0100
> >>>
> >>>> Nice patch, thanks :)
> >>>>
> >>>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >>> I like it too, but please resubmit once we have at least
> >>> one example user submitted.
> >>>
> >> I successfully tested following patch.
> >=20
> > Great! But, I see, checking if realloc_netdev_mq() use is always le=
gal
> > (before register_netdev()) is not trivial in this driver. (I have s=
ome
> > suspicions around ixgbe_resume().) I wonder, if there should be add=
ed
> > some debugging for this.
>=20
> Yes, probably
>=20
> Or even better, allowing realloc_netdev_mq() to be called even after
> register_netdev() :)

We should try to avoid it because of clashes with qdisc initialization
(especially wrt. preserving stats). But mainly it's about knowing the
exact reason why this thing (probing the hardware for max mq
capabilities) can't be finished before register_netdev(). I'll try to
look at this more.

Jarek P.

>=20
> bnx2 for example could not be patched easily, following patch doesnt =
work.
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 4cae2a8..8bd5d0d 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6177,6 +6177,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_ms=
i)
> =20
>  	bp->num_tx_rings =3D rounddown_pow_of_two(bp->irq_nvecs);
> -	bp->dev->real_num_tx_queues =3D bp->num_tx_rings;
> +	realloc_netdev_mq(bp->dev, bp->num_tx_rings);
> =20
>  	bp->num_rx_rings =3D bp->irq_nvecs;
>  }
>=20
