From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v2 1/4] ipv4: add option to drop unicast encapsulated in
 L2 multicast
Date: Wed, 04 Nov 2015 22:35:58 +0100
Message-ID: <1446672958.13649.4.camel@sipsolutions.net>
References: <1446654127-26826-1-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1511042215570.2194@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.11.1511042215570.2194-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-11-04 at 22:59 +0200, Julian Anastasov wrote:
>=C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Patches 1 and 3 look =
correct to me,
>=20
> Reviewed-by: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>

Thanks for checking!

> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0If the patches are lo=
st in the merge window you
> can also consider one minor optimization, see below...

Oh, yeah, they probably are - sorry Dave.

> > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else if (rt->rt_type =3D=3D RTN_BR=
OADCAST)
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else if (rt->rt_type =3D=3D RTN_BR=
OADCAST) {
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb-
> >len);
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else {
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0} else if (unlikely(s=
kb->pkt_type !=3D PACKET_HOST)) {
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0May be such check can=
 save some cycles because
> it is more common to see PACKET_HOST packets...

I had thought about that based on your earlier comments, but then I
didn't quite see the point. However, perhaps we could invert the check
below to check the pkt_type first, hoping it'll have some kind of cache
effect?

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
