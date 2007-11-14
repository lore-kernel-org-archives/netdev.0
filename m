From: Nj A <nj_a83@yahoo.fr>
Subject: Re : Bug in using inet_lookup ()
Date: Wed, 14 Nov 2007 13:12:11 +0000 (GMT)
Message-ID: <867900.85129.qm@web26107.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26107.mail.ukl.yahoo.com ([217.146.182.148]:43852 "HELO
	web26107.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751697AbXKNNMP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 08:12:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I suspected it could be that. However, can't see in ip_rcv the right po=
rtion that can help.
Any further tip please?

Regards,
----- Message d'origine ----
> De : Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> =C0 : Nj A <nj_a83@yahoo.fr>
> Cc : netdev@vger.kernel.org
> Envoy=E9 le : Mercredi, 14 Novembre 2007, 12h13mn 05s
> Objet : Re: Bug in using inet_lookup ()
>=20
> On Wed, Nov 14, 2007 at 09:26:18AM +0000, Nj A (nj_a83@yahoo.fr) wrot=
e:
> > /* The kernel TCP hashtable */
> > struct inet_hashinfo __cacheline_aligned tcp_hashinfo =3D {
> > .lhash_lock =3D __RW_LOCK_UNLOCKED (tcp_hashinfo.lhash_lock),
> > .lhash_users =3D ATOMIC_INIT (0),
> > .lhash_wait =3D __WAIT_QUEUE_HEAD_INITIALIZER (tcp_hashinfo.lhash_w=
ait),
> > };
> > ...
> > struct sock *sk;
> > struct sk_buff *skb;
> > skb =3D alloc_skb (MAX_TCP_HEADER + 15, GFP_KERNEL);
> > if (skb =3D=3D NULL)
> > printk ("%s: Unable to allocate memory \n", __FUNCTION__);
> > sk =3D inet_lookup (&tcp_hashinfo, ip_src, src_port, ip_dst, dst_po=
rt, inet_iif
> (skb));
> > if (!sk)
> > ...
> > This portion of code seems to cause the kernel to panic due to dere=
ferencing a
> NULL pointer.
> > Can anyone please tell me what is the error above?
> > Best Regards,
>=20
> Where exactly? Likely in inet_iif(), since it dereferences dst (routi=
ng
> info), which is not presented after simple alloc_skb().
> You have to setup skb correctly, check how ip_rcv() does it.
>=20
> --=20
> Evgeniy
> Polyakov
>


      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail=20
