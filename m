From: Nj A <nj_a83@yahoo.fr>
Subject: Re : Re : Bug in using inet_lookup ()
Date: Wed, 14 Nov 2007 16:47:22 +0000 (GMT)
Message-ID: <256275.33084.qm@web26104.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26104.mail.ukl.yahoo.com ([217.146.182.145]:46067 "HELO
	web26104.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753463AbXKNQrY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 11:47:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By setting the ID of the ingress device to the inet_lookup() to 0, the =
machine reboots automatically.
Setting proc/sys/kernel/panic* to non zero values dosn't help more..

Cheers,

----- Message d'origine ----
> De : Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> =C0 : Nj A <nj_a83@yahoo.fr>
> Cc : netdev@vger.kernel.org
> Envoy=E9 le : Mercredi, 14 Novembre 2007, 14h31mn 18s
> Objet : Re: Re : Bug in using inet_lookup ()
>=20
> On Wed, Nov 14, 2007 at 01:12:11PM +0000, Nj A (nj_a83@yahoo.fr) wrot=
e:
> > I suspected it could be that. However, can't see in ip_rcv the righ=
t portion
> that can help.
> > Any further tip please?
>=20
> It is ip_rcv_finish() called from ip_rcv():
> if (skb->dst =3D=3D NULL) {
> int err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
> skb->dev);
> if (unlikely(err)) {
> if (err =3D=3D -EHOSTUNREACH)
> IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
> else if (err =3D=3D -ENETUNREACH)
> IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
> goto drop;
> }
> }
>=20
> So you will have to specify device, you got your skb via.
> Actually it is not exactly needed in some cases, you will need interf=
ace
> index (dev->ifindex). You can find socket by using that number instea=
d
> of dereferencing dst.
>=20
> --=20
> Evgeniy
> Polyakov
>


      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail=20
