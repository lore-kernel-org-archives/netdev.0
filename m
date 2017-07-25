From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 09/18] net: mvpp2: use named interrupts
Date: Tue, 25 Jul 2017 10:45:58 +0200
Message-ID: <20170725084558.GB2860@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-10-antoine.tenart@free-electrons.com>
 <80d4b082-a5ed-73da-0634-8295996dc29d@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="CUfgB8w4ZwR/yMy5"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48963 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdGYKl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:41:28 -0400
Content-Disposition: inline
In-Reply-To: <80d4b082-a5ed-73da-0634-8295996dc29d@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sergei,

On Mon, Jul 24, 2017 at 07:49:03PM +0300, Sergei Shtylyov wrote:
> On 07/24/2017 04:48 PM, Antoine Tenart wrote:
> > +	if (of_get_property(port_node, "interrupt-names", NULL)) {
> > +		port->irq =3D of_irq_get_byname(port_node, "rx-shared");
> > +		if (port->irq <=3D 0) {
> > +			err =3D (port->irq =3D=3D -EPROBE_DEFER) ?
> > +			      -EPROBE_DEFER : -EINVAL;
>=20
>    Perhaps better:
>=20
> 		err =3D port->irq ?: -EINVAL;

Sure.

> > +			goto err_free_netdev;
> > +		}
> > +	} else {
> > +		/* kept for dt compatibility */
> > +		port->irq =3D irq_of_parse_and_map(port_node, 0);
> > +		if (port->irq <=3D 0) {
>=20
>    Note that irq_of_parse_and_map() returns *unsigned int*, so negative
> error codes are not possible, 0 indicates bad IRQ.

That right, I'll fix that!

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--CUfgB8w4ZwR/yMy5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll3BUYACgkQXE2LyK3b
vNgoMBAAhXe9dlt2y79V7wAOZrQzlmGEn19dNkER/8Fp16nFSJewSM7GxC7ArW1m
NXvcZZJoJjllErIiCTt/w+R7qik3QnPLYF9AvgaBxkRW+mBrm/6vCEtha+ZlQo+a
lexnhJBt6oIbKjhHQidSLbRuHb0/Rkxm1/FJlReT81SO68iQ4z/jgobRCaX+uW8n
ytDvtD7y9PPyIZd5CPkaY0YqJOrbyrYUv1+I/sv4Fvbgxj4q6xZ5BYhVR8s3/Cm+
RCo0/gakVCEmlyFw8AdqzpXPENKj4P84KXNXjK5GnSaknaxCyeP4BE0f7k397XI4
caLFnRbKIWTOM9TGldfKFdxMczCdOeA9hS0YRZ+SUVN+Zhp3DDhT5V4nOeFnN31/
IeUrsKRTeSC/Ujcxzp1PCCtUYOjV09JPKRskCy8z6/b5pCQ9y53zSfdxV+psBhDT
vXo2Lj7sZAjbYE7oQogJB+0NYInP3sAX4bKJxaco+mnH+9ugzNZXVPZv3yNKiIqT
HuBd+080ls2EakUGsHqGBjF2SMrGBRfZJdSK3YC+XMBGM6fi1QVjDciL58uN6EOa
qf6kuOv3lCuCbsOouq0ctt6TlL9p5OYlGbjjsYMi3HuJu6gIwgS/BkPmMNxmTvYi
ggd/2xmV3xCAVjRE3/q5sArOKWRKgfgWKkiPWGOjzH2GIZCcswM=
=+cuq
-----END PGP SIGNATURE-----

--CUfgB8w4ZwR/yMy5--
