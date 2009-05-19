From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 19 May 2009 23:09:37 +0200
Message-ID: <20090519210937.GA4850@ami.dom.local>
References: <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <4A09CD6B.5070604@cosmosbay.com> <20090518.221956.153457626.davem@davemloft.net> <4A130C0E.6000507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:32936 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbZESVLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:11:50 -0400
Received: by bwz22 with SMTP id 22so55219bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 14:11:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A130C0E.6000507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 09:44:14PM +0200, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Tue, 12 May 2009 21:26:35 +0200
> >=20
> >> [PATCH] net: release dst entry in dev_hard_start_xmit()
> >  ...
> >> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> >=20
> > Applied, thanks Eric.
> >=20
> > Eric, please followup and double-check the pppoe paths
> > that Jarek mentioned.  I never saw that fully resolved.
> >=20
>=20
> [PATCH] ppp: unset IFF_XMIT_DST_RELEASE in ppp_setup()
>=20
> Jarek pointed pppoe can call back dev_queue_xmit(), and might need
> skb->dst, so its safer to unset IFF_XMIT_DST_RELEASE on ppp devices.

Hmm... Of course, this patch looks OK to me, but actually my main
concern was more general. We avoid adding such flags for each "real"
dev, but if so IMHO it would be safer to generally add them to all
"virtual" devs - needed or not. You prefer to do this only where
necessary, but it's not always clear if it's omitted on purpose or
by chance. So, now I'm wondering about xen-netfront - needlessly I
hope ;-)

Jarek P.

>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
> index 8ee9142..639d11b 100644
> --- a/drivers/net/ppp_generic.c
> +++ b/drivers/net/ppp_generic.c
> @@ -1054,6 +1054,7 @@ static void ppp_setup(struct net_device *dev)
>  	dev->type =3D ARPHRD_PPP;
>  	dev->flags =3D IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
>  	dev->features |=3D NETIF_F_NETNS_LOCAL;
> +	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>  }
> =20
>  /*
>=20
