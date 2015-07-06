From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 4/6] net: mvneta: Handle per-cpu interrupts
Date: Mon, 6 Jul 2015 15:00:38 +0200
Message-ID: <20150706130038.GL3269@lukather>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
 <1435933551-28696-5-git-send-email-maxime.ripard@free-electrons.com>
 <20150705123708.GA24162@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zH41lVBEV8cLJnCl"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46335 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753234AbbGFNFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 09:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20150705123708.GA24162@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zH41lVBEV8cLJnCl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Willy,

On Sun, Jul 05, 2015 at 02:37:08PM +0200, Willy Tarreau wrote:
> Hi Maxime,
>=20
> On Fri, Jul 03, 2015 at 04:25:49PM +0200, Maxime Ripard wrote:
> > Now that our interrupt controller is allowing us to use per-CPU interru=
pts,
> > actually use it in the mvneta driver.
> >=20
> > This involves obviously reworking the driver to have a CPU-local NAPI
> > structure, and report for incoming packet using that structure.
> >=20
> > Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
>=20
> This patch breaks module build of mvneta unless you export request_percpu=
_irq :
>=20
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index ec31697..1440a92 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -1799,6 +1799,7 @@ int request_percpu_irq(unsigned int irq, irq_handle=
r_t handler,
> =20
> 	return retval;
>  }
> +EXPORT_SYMBOL_GPL(request_percpu_irq);

Ah, right. Thanks!

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--zH41lVBEV8cLJnCl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVmnv2AAoJEBx+YmzsjxAgzawP/3/MTe0IHoCJki2FsNUf19cZ
52dkmohwPbmRtiFwRTM7U6isAxOyS1yWKreodmvym+UPTO40HKoUG55kf7roN02n
FOlGRRUkZ7r6jC1pe1bu4wNiecpuZTS1Mopvz4pH8KyPgBEbY1qjDQjCypfeMJaF
LMqeE2OuHFsUk8FWYVG5fScdAaUqteq4EUTZV5Byu5NdJMLymz7Jd8SvHy/w7gNF
4Qve0v7BIBjgv3iKb93URZfSJdNpRFr+svJUZk61TJTZDenjxEe6bO4Z4QLeEG1n
xevzpovyCK7FqQdnqAMKMtYIB7htHgxwkouRKnPdz0ElTLxz5RRKqlpjCXSBXkkr
/aAUrj/RmTNFmQd1VJxP1e+GsJu7xaZUgTpTI5Owa5ec4eIuC2j+8EffwZC9aRm+
vNevAuO3FEfSkWuIxoskhw3SkuTn5CQ9b+rCm/t7eeRnNhdHC4OXFr6f4bZ9KL5l
GCc8IMY0iiskCTT0Q1DMm5ODcavFbahgWY7aenuCrVih8Naa9EBI6y15FCEe7RfG
iqgznsnHaIk606VcK8Qm7oRIGIOfTuv8biXJrRnvBnQu/wcbfA7WBWRqn6DINYOP
XjymlVKzfyagKZ2qbqcuD7PMgoWK5lQvbwsO9WfwERfdLHu9gGN/7tBMAW1eEw9m
Ae8PC+X9DUjWnsPojzaf
=2KKa
-----END PGP SIGNATURE-----

--zH41lVBEV8cLJnCl--
