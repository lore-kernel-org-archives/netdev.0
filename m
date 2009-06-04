From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Thu, 04 Jun 2009 16:12:29 +0200
Message-ID: <1244124749.22576.71.camel@johannes.local>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
	 <1244021964.10665.5.camel@johannes.local>
	 <20090603.030911.162861804.davem@davemloft.net>
	 <20090603105256.GB20508@doriath.ww600.siemens.net>
	 <1244027110.1693.9.camel@johannes.local>
	 <20090603122744.GC20508@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-1bMfWXsvCYywcrD7EZsF"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	sfr@canb.auug.org.au, slapin@ossfans.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42435 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbZFDOMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 10:12:37 -0400
In-Reply-To: <20090603122744.GC20508@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1bMfWXsvCYywcrD7EZsF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-03 at 16:27 +0400, Dmitry Eremin-Solenikov wrote:

> > > +/* commands */
> > > +/* REQ should be responded with CONF
> > > + * and INDIC with RESP
> > > + */
> > > +enum {
> >=20
> > kernel-doc explaining the commands would be immensely helpful.
>=20
> What explanations whould you like to see? These commands are described
> in the IEEE 802.15.4 standard.

Well, for example which arguments they require...

> > > +#ifdef __KERNEL__
> > > +struct net_device;
> > > +
> > > +int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee802=
154_addr *addr, u8 cap);
> > > +int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_ad=
dr, u8 status);
> > > +int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee=
802154_addr *addr, u8 reason);
> > > +int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status=
);
> > > +int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8=
 scan_type, u32 unscanned,
> > > +		u8 *edl/*, struct list_head *pan_desc_list */);
> > > +int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u1=
6 coord_addr); /* TODO */
> > > +#endif
> >=20
> > Why not just use two header files, one in net/ and one in linux/?
>=20
> What would you suggest to put into the linux/ header and what in the
> net/ one?

userspace vs. in-kernel separation

> > > +static int ieee802154_nl_put_failure(struct sk_buff *msg)
> > > +{
> > > +	void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh is r=
ight at the start of msg */
> > > +	genlmsg_cancel(msg, hdr);
> > > +	nlmsg_free(msg);
> > > +	return -ENOBUFS;
> > > +}
> >=20
> > This seems weird.
>=20
> Why?

Because it's strange to cancel then free?

> > > +static int ieee802154_associate_req(struct sk_buff *skb, struct genl=
_info *info)
> > > +{
> > > +	struct net_device *dev;
> > > +	struct ieee802154_addr addr;
> > > +	int ret =3D -EINVAL;
> > > +
> > > +	if (!info->attrs[IEEE802154_ATTR_CHANNEL]
> > > +	 || !info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
> > > +	 || (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] && !info->attrs[IE=
EE802154_ATTR_COORD_SHORT_ADDR])
> > > +	 || !info->attrs[IEEE802154_ATTR_CAPABILITY])
> > > +		return -EINVAL;
> >=20
> > That's some odd coding style.
>=20
> Could you please elaborate this? What seems odd to you?

if (X
    && Y)

vs

if (X &&
    Y)

where the latter is used for all other sources files in the kernel. Try
applying that to _all_ your patches while you rework the sources to fit
into 80 columns.

johannes

--=-1bMfWXsvCYywcrD7EZsF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKJ9ZKAAoJEODzc/N7+QmaP30P/2eTUPIJOD7ZyD5sC7zCXkXm
cUDPVT9ozDBrfMVIpB7uNPFJb/2Jfrr5wEcZCwZ56el4Cq4vB6NqlpkXZ1zs6uGJ
7ISjqQmVK/iKzfPH7tUR4j6cvrEwPdiX87moeX6M+HXxBkiw2p8jJNtJZexdoYIK
ETIO6QjsT8ABnWAjrkttVp96z21HtXwPELNIVh88hnMO4vK94fNC872MwyMjY2n+
KY4oMFrCcgvbawVqDBYdtWLVslVV33d9COF2OTjLTvkc9aR2AAXnd1kpZOMPkB9s
FNdKNIZoNwhLPM0re4plGfW5JELvDt9GNtd6eJ8p/+dxnK0RYL7USLzX7NsuvK1u
JoqADzPm02EoqbFZ3M+EeKX4apajo9UNspEmuegCruIr4yTKMYHp9RIby4dIL+zK
WGfEGf+orGWyL9LcURck0USOlajbMqJ591WSr5LEcbUPw1Qrkia6peZs8ZvuH+V0
sY1rAXu26/drCk5BPMdRHiQmPCwTWB2ZsDH/6MGv4HNXkZe8qPUZ3PX83wHBgs4r
vd4pmXOl4J4hUN+kH7S3g6MsxY8GynGeCm5OcKl7UBal6XEDdKfize5+1FSybZ6Z
YOZxmI0CR3HGyCNiBT1vmDJ5BvGnMzLZuBMU9lME7EHs+WbohF7yGuaTKNjNxO/t
TgM7Vve/X9JNgOcnsPLv
=zBxM
-----END PGP SIGNATURE-----

--=-1bMfWXsvCYywcrD7EZsF--

