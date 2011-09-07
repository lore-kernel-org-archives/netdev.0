From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 07:08:20 +0200
Message-ID: <1315372100.3400.76.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: "Yan, Zheng" <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50426 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab1IGFIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 01:08:34 -0400
Received: by wwf5 with SMTP id 5so7054132wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 22:08:33 -0700 (PDT)
In-Reply-To: <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 12:36 +0800, Yan, Zheng a =C3=A9cr=
it :

> I guess you misunderstood this code. Set scm_ref to false means skb w=
ill inherit
> sender's reference. Then we call unix_scm_to_skb() with parameter
> 'ref' =3D=3D false.
> So it doesn't get additional reference. I admit my patch is confusing=
,
> but I think
> Tim's new patch is OK. (even in the case of fail skb allocation or
> user->kernel copy)
>=20

I want to be able to review the code now, and in two or three years too=
,
without spending hours and hours.

Could you _please_ guys send a patch, with :

1) A good changelog : In this confusing area, this is probably more
important than actual code.

2) right logic and right variable names

I am sorry, but this is not good :

+               /* encode scm in skb and use the scm ref */
+               ref_avail =3D false;
+               if (sent + size < len) {=20
+                       /* Only send the fds in the first buffer */
+                       /* get additional ref if more skbs will be crea=
ted */
+                       err =3D unix_scm_to_skb(siocb->scm, skb, !fds_s=
ent, true);
+                       ref_avail =3D true;
+               } else
+                       err =3D unix_scm_to_skb(siocb->scm, skb, !fds_s=
ent, false);
