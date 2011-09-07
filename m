From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 13:20:56 +0800
Message-ID: <4E66FF38.9000107@intel.com>
References: <4E631032.6050606@intel.com>  <1315326326.2576.2980.camel@schen9-DESK>  <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1315335019.2576.3048.camel@schen9-DESK>  <1315335660.3400.7.camel@edumazet-laptop>  <1315337580.2576.3066.camel@schen9-DESK>  <1315338186.3400.20.camel@edumazet-laptop>  <1315339157.2576.3079.camel@schen9-DESK>  <1315340388.3400.28.camel@edumazet-laptop>  <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com> <1315372100.3400.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <yanzheng@21cn.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21587 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432Ab1IGFU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 01:20:58 -0400
In-Reply-To: <1315372100.3400.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2011 01:08 PM, Eric Dumazet wrote:
> Le mercredi 07 septembre 2011 =C3=A0 12:36 +0800, Yan, Zheng a =C3=A9=
crit :
>=20
>> I guess you misunderstood this code. Set scm_ref to false means skb =
will inherit
>> sender's reference. Then we call unix_scm_to_skb() with parameter
>> 'ref' =3D=3D false.
>> So it doesn't get additional reference. I admit my patch is confusin=
g,
>> but I think
>> Tim's new patch is OK. (even in the case of fail skb allocation or
>> user->kernel copy)
>>
>=20
> I want to be able to review the code now, and in two or three years t=
oo,
> without spending hours and hours.
>=20
> Could you _please_ guys send a patch, with :
>=20
> 1) A good changelog : In this confusing area, this is probably more
> important than actual code.
Sorry for my poor English.

>=20
> 2) right logic and right variable names
>=20
> I am sorry, but this is not good :
>=20
> +               /* encode scm in skb and use the scm ref */
> +               ref_avail =3D false;
> +               if (sent + size < len) {=20
> +                       /* Only send the fds in the first buffer */
> +                       /* get additional ref if more skbs will be cr=
eated */
> +                       err =3D unix_scm_to_skb(siocb->scm, skb, !fds=
_sent, true);
> +                       ref_avail =3D true;
> +               } else
> +                       err =3D unix_scm_to_skb(siocb->scm, skb, !fds=
_sent, false);
>=20
>=20

Is code like this OK? Thanks
---
	if (sent + size < len) {=20
		/* Only send the fds in the first buffer */
		/* get additional ref if more skbs will be created */
		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
	} else {
		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
		ref_avail =3D false;
	}
