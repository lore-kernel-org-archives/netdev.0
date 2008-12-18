From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Fri, 19 Dec 2008 00:30:03 +0100
Message-ID: <1229643003.3601.58.camel@johannes.berg>
References: <20081217211628.GD7356@hmsreliant.think-freely.org>
	 <20081217133131.44a4f67f@extreme>
	 <20081218011306.GA32191@hmsreliant.think-freely.org>
	 <20081217.192936.169928910.davem@davemloft.net>
	 <20081218195236.GA5191@hmsreliant.think-freely.org>
	 <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk>
	 (sfid-20081219_002215_896671_C1B9AA7B)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aUSwMccb/AzIQX1j8uWf"
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59066 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbYLRXaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 18:30:17 -0500
In-Reply-To: <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk> (sfid-20081219_002215_896671_C1B9AA7B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aUSwMccb/AzIQX1j8uWf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-12-18 at 22:40 +0000, Ben Hutchings wrote:

> >  	if (rx_packets < budget) {
> >  		/* There is no race here; although napi_disable() will
> > -		 * only wait for netif_rx_complete(), this isn't a problem
> > +		 * only wait for netif_rx_complete(this isn't a problem
> >  		 * since efx_channel_processed() will have no effect if
> >  		 * interrupts have already been disabled.
> >  		 */
> [...]
>=20
> You'll want to exclude comments from your search-and-replace.

Or just use spatch (http://www.emn.fr/x-info/coccinelle/)

Should be as easy as:

@@
expression A, B;
@@
-netif_rx_schedule(A, B);
+netif_rx_schedule(B);

etc.

johannes

--=-aUSwMccb/AzIQX1j8uWf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJStz4AAoJEKVg1VMiehFYORoP/2MMPHZOh86np5Vu7v629pyR
fRaueNsrp1TVKgZ/p8waaEbu8WiB45Joo0h+ByKzx/yeNnLqN1ZEIOQmn5Nz0Es9
fyhIhv3m20B+nrUEBxjMvfuXK7TE2epEKYbk7K4/UiDQTDzlsDMA4ej5fCBVB0bl
YjFPA6GHJINy/ur/PTL6AqiChsMVqLa9PfLC/Id+DtK8EZWENjGM8AX0E309ojkf
YWqVOMvKvw6VBlmnhVITgMu/GOjW6rgPZVo/zf82AjrfRA1aaiFjh9HgSETrWY1B
nbqp/VVno8zOCmeIHBGhlX+YesMrVFSxUV2X4q10pi9EMsOvsWQt3+sVhV93xOP8
iVFXoOhoAHrnMG+GlJRh0RANrgRsJcxoSCxV1UOKt8czUZ9CYXun82rV3FbP/WpR
kwbBeSDlo6gu3MkrlSDZ1fyLw6mhDQUWFwhSmT12gMAmyU7+JeVOh0bU91PNODTT
7eUGSSmt04eHMqpmf5EtLimHXJtH39mYOYbuoGypuxrJVv3jm0DWmy8XYQA3Y/Zr
SKo4BQC0Ti76zlRMrlKPHwW4LdOdteHisqSg3MIYlC2rJNhMgHYMRyl0QR1ZuUKs
thu6jDnnKG3RVFlN+Vd3Ry064rPB6DgZVGEXgwbqxYWV+TzEiV/YMzX3XBcXBlAK
LxkOvB3YCdM4/w/pq4B8
=hXjn
-----END PGP SIGNATURE-----

--=-aUSwMccb/AzIQX1j8uWf--

