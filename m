From: Daniele Fucini <dfucini@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 1 Dec 2015 20:13:28 +0100
Message-ID: <20151201191328.GA1310@Fux-PC>
References: <20151201010005.GA23175@Fux-PC>
 <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
 <20151201111943.GA4036@Fux-PC>
 <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448979337.25582.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZPt4rx8FFjLCG7dd"
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33383 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbbLATNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 14:13:34 -0500
Received: by wmuu63 with SMTP id u63so4595693wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 11:13:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448979337.25582.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I can't be 100% sure but after running transmission for over an hour
without any problems I'd say this fix worked. I'll keep it running for a
while so if it suddently freezes again I'll report it, but I hope it
won't be the case.

Daniele

On Tue, Dec 01, 2015 at 06:15:37AM -0800, Eric Dumazet wrote:
>=20
> Please try following fix :
>=20
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index f43c8f33f09e..72f2c1dfdcde 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -759,6 +759,8 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsi=
gned int n)
>  			WARN_ON(parentid !=3D TC_H_ROOT);
>  			return;
>  		}
> +		if (sch->flags & TCQ_F_MQROOT)
> +			return;
>  		cops =3D sch->ops->cl_ops;
>  		if (cops->qlen_notify) {
>  			cl =3D cops->get(sch, parentid);
>=20
>=20
>=20

--ZPt4rx8FFjLCG7dd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXfFYAAoJEEYRza8bUKw+AO0H/RwGrXt9bcGd1mySDZvlMo8k
A+1uvT+yjg2CWcrWJqAL33UqPJOr2m2/yBeQltJFMtSBeiN/H08Aj0XsYEcvlAhv
EjuY9gU+j6jKPoCWno3fxw7KTIAvmJXWnnUFey2vWIkXrLs1F55RaifSURXWl1Ou
M6xhfolHmwYVtspnZng19GhrRRpOqgoUEgY9ZX2DD4bYXtpItPRWuqu4+t6rnXN/
4weu/mBmvC8fIa1gBgkUDPxB2sjAxzGL4eltG2ljr3/Dbv4ufC9hpIRmG006QDoL
JNAbQaViLGD81n53dI5AQhyDI2/cD3qdEkhCfprKogPeaj9Gq6mb33f1OKVLtCM=
=eLrN
-----END PGP SIGNATURE-----

--ZPt4rx8FFjLCG7dd--
