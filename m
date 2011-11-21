From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 23:30:10 +0800
Message-ID: <1321889410.14281.31.camel@barry.pixelworks.com>
References: <1321887946.14281.27.camel@barry.pixelworks.com>
	 <1321889066.10470.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39953 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab1KUPbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 10:31:15 -0500
Received: by iage36 with SMTP id e36so7415849iag.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 07:31:15 -0800 (PST)
In-Reply-To: <1321889066.10470.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-21 at 16:24 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 =C3=A0 23:05 +0800, Jun Zhao a =C3=A9crit :
> > When add sources to interface failure, need to roll back the sfcoun=
t[MODE]=20
> > to before state. We need to match it corresponding.=20
> >=20
>=20
> Missing "---" separator
>=20
> > diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> > index c7472ef..276719a 100644
> > --- a/net/ipv4/igmp.c
> > +++ b/net/ipv4/igmp.c
> > @@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in=
_dev, __be32 *pmca, int sfmode,
> >  	if (err) {
> >  		int j;
> > =20
> > -		pmc->sfcount[sfmode]--;
> > +		if(!delta)
>=20
> Missing space, should be  : if (!delta)
>=20
> > +			pmc->sfcount[sfmode]--;
> >  		for (j=3D0; j<i; j++)
> >  			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
> >  	} else if (isexclude !=3D (pmc->sfcount[MCAST_EXCLUDE] !=3D 0)) {
> >=20
> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> >=20
>=20
> Your "Signed-off-by:" should come before actual patch
>=20
> Please read Documentation/SubmittingPatches
>=20
> Thanks
>=20
>=20
>=20

Tks, Eric Dumazet , I will re-submit this patch and follow the format.
