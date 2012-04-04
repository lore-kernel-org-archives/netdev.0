From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH v6 1/2] Ethernet driver for the WIZnet W5300 chip
Date: Wed, 4 Apr 2012 11:01:49 +0100
Message-ID: <20120404100148.GB3002@opensource.wolfsonmicro.com>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
 <1333450726-24455-2-git-send-email-msink@permonline.ru>
 <20120403133619.GA3960@sirena.org.uk>
 <4F7BE7A4.1060202@permonline.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F7BE7A4.1060202@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 04, 2012 at 12:18:12PM +0600, Mike Sinkovsky wrote:
> 03.04.2012 19:36, Mark Brown =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB:

> >...you use devm_request_threaded_irq() here and rely on it for cleanup.
> >Are you sure there's no possibility of the interrupt firing after you
> >start to tear down the device?

> >By using a specifically threaded IRQ you're also adding a performance
> >overhead for no good reason if you can call netdev_carrier_*() from IRQ
> >context and the GPIO is capable of generating a hard IRQ.  If you use
> >request_any_context_irq() instead then the driver will get a hard IRQ if
> >that's supported.

> There isn't devm* variant of request_any_context_irq(), and using
> plain version looks inconsistent with other resources handling.
> Anyway, this is not performance critical procedure, and latency
> around 100 millisecond is acceptable. Some our boards even don't
> have this gpio at all, and nothing bad happens, just userspace
> doesn't know is carrier on or off.

None of this addresses the primary concern which is that because you're
not (as far as I can tell) ensuring that the interrupt won't fire the
driver might crash if the interrupt fires in between the resources it
needs to handle the interrupt being deallocated and the interrupt being
unregistered.  Managed interrupts are relatively tricky to use because
of this issue, with most things like memory it doesn't matter exactly
when it's deallocated but interrupts can potentially trigger actions
themselves.

If you can use it and devm_request_any_context_irq() doesn't exist it'd
be better to add it.

--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPfBwGAAoJEBus8iNuMP3d2HwP/27y84pdbHqBmSWGNmwuq4ya
E33zPipfC7yjRuB/ABH7otJ0FLsrwUVbot7XYVu5HqVsMMzcxpcI6g1u5fvTNgRH
Gy6IdDKdavoKKWdOFEfLuZwC544jnRa9hUXU7jMOycrv5iZsZ1z2LU0N6OJHPHZJ
w9wKZoosPaluO9IHnPp4F31O9nFirP4h9tv3NgQoTBt8cfT017tf8ZuWTs+D4Xlb
XH1qJfpvcYQA68bVMYIABFcO+RrcGmG8RA8bJ1i30UFuces0Y6E8UoLiOhvSB9Vm
B00Jsh+SlZZpVyZD1UiaEt1uSOWu/05In3tpw8UAtu5r+EuXGYZb7yXtKlgyw0px
XYhrVX7hY4iuY3rMuT4xEKv6UMRgcJ8MwMElucksfcOoBZjegPs8hg53FzdwcC7b
FxhEkew+CTvNKkNv0nMf+UuO1rrgGSpoKeN4VlJei8o8k2g+lQUUNbEqDlfrHtsS
eTeXviSODQ5/qmMHpBdrtSa8OSWyKhcH92+M+e8c5KmQUA5S6Hs6cOGr0FE2wmBz
+R8ZXp64/4j2lxjSoOvLnrWBQICYb7cUEOh83nt4js+ovAxszMHHyog4YrfJPOWQ
t9FYd+lCQ8t/KeE7Yk/750yQpiAjYNJj43LK9A+dYJLqmrVXQEIc2ysN1Q1n3+8q
2mTsk08t0IW9h3WEqIHv
=v9Mm
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--
