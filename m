From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 23:26:06 +0200
Message-ID: <1315430766.2532.1.camel@edumazet-laptop>
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
	 <1315372100.3400.76.camel@edumazet-laptop>  <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48419 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab1IGV0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 17:26:12 -0400
Received: by wyh22 with SMTP id 22so80849wyh.19
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2011 14:26:11 -0700 (PDT)
In-Reply-To: <1315396903.2364.23.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 05:01 -0700, Tim Chen a =C3=A9crit=
 :
> On Wed, 2011-09-07 at 09:45 +0200, Eric Dumazet wrote:
> > Le mercredi 07 septembre 2011 =C3=A0 13:20 +0800, Yan, Zheng a =C3=A9=
crit :
> >=20
> > > Is code like this OK? Thanks
> > > ---
> > > 	if (sent + size < len) {=20
> > > 		/* Only send the fds in the first buffer */
> > > 		/* get additional ref if more skbs will be created */
> > > 		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
> > > 	} else {
> > > 		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
> > > 		ref_avail =3D false;
> > > 	}
> > >=20
> > >=20
> >=20
> > Whats wrong with using ref_avail in the unix_scm_to_skb() call itse=
lf ?
> >=20
> > something like :
> >=20
>=20
> Eric,
>=20
> Your updated patch looks good when I tested it on my side.  It makes =
the
> patch much more readable.  If this patch looks good with you and Yan
> Zheng, can you and Yan Zheng add your Signed-off-by to the patch?
>=20
> Jiri, Sedat or Valdis, if you can verify that the patch fixed commit
> 0856a30409, that will be appreciated.
>=20
> Eric, are you planning to do a fast path patch that doesn't do pid re=
f
> for the case where CONFIG_PID_NS is not set?
>=20

Yes, I'll try to cook a patch.

> Thanks.
>=20
> Tim
>=20
> ---
>=20
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential reference=
s
> in Unix socket's send and receive path) introduced a use-after-free b=
ug.
> The sent skbs from unix_stream_sendmsg could be consumed and destruct=
ed=20
> by the receive side, removing all references to the credentials,=20
> before the send side has finished sending out all=20
> packets. However, send side could continue to consturct new packets i=
n the=20
> stream, using credentials that have lost its last reference and been
> freed. =20
>=20
> In this fix, we don't steal the reference to credentials we have obta=
ined=20
> in scm_send at beginning of unix_stream_sendmsg, till we've reached
> the last packet.  This fixes the problem in commit 0856a30409.
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
> Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> ---

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
