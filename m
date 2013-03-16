From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net,stable-3.8] net: cdc_ncm, cdc_mbim: allow user to
 prefer NCM for backwards compatibility
Date: Sat, 16 Mar 2013 17:51:21 +0000
Message-ID: <1363456281.3937.203.camel@deadeye.wl.decadent.org.uk>
References: <1363259113-6909-1-git-send-email-bjorn@mork.no>
	 <1363324945.3937.144.camel@deadeye.wl.decadent.org.uk>
	 <87ppz14030.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vpYt+ITSaAWfAYBqQ/o2"
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50439 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755984Ab3CPRve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 13:51:34 -0400
In-Reply-To: <87ppz14030.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vpYt+ITSaAWfAYBqQ/o2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-03-15 at 08:02 +0100, Bj=C3=B8rn Mork wrote:
> Ben Hutchings <ben@decadent.org.uk> writes:
>=20
> > On Thu, 2013-03-14 at 12:05 +0100, Bj=C3=B8rn Mork wrote:
> >> commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM devi=
ces")
> >> introduced a new policy, preferring MBIM for dual NCM/MBIM functions i=
f
> >> the cdc_mbim driver was enabled.  This caused a regression for users
> >> wanting to use NCM.
> >>=20
> >> Devices implementing NCM backwards compatibility according to section
> >> 3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a singl=
e
> >> USB function, using different altsettings.  The cdc_ncm and cdc_mbim
> >> drivers will both probe such functions, and must agree on a common
> >> policy for selecting either MBIM or NCM.  Until now, this policy has
> >> been set at build time based on CONFIG_USB_NET_CDC_MBIM.
> >>=20
> >> Use a module parameter to set the system policy at runtime, allowing t=
he
> >> user to prefer NCM on systems with the cdc_mbim driver.
> >>=20
> >> Cc: Greg Suarez <gsuarez@smithmicro.com>
> >> Cc: Alexey Orishko <alexey.orishko@stericsson.com>
> >> Reported-by: Geir Haatveit <nospam@haatveit.nu>
> >> Reported-by: Tommi Kyntola <kynde@ts.ray.fi>
> >> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D54791
> >> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> >> ---
> >>=20
> >> We now have two users independently reporting this as a 3.8 regression=
,
> >> so something needs to be done.  I am not sure if adding a new module
> >> parameter is acceptable for stable, but this problem is definitely a
> >> regression and no other solutions came up in response to my RFC.
> >>=20
> >> The only real alternative I see for stable, is disabling MBIM support
> >> on any dual NCM/MBIM function.  Which of course will be a regression
> >> for any user wanting MBIM, making it unacceptable.
> > [...]
> >
> > It definitely makes sense for this to be a run-time parameter.  And the
> > default seems correct for custom kernels.
> >
> > For a distribution kernel - at least for Debian, where we can't assume
> > kernel and userland are always updated together - I think the
> > compile-time default should be false, and the userland package
> > (presumably ModemManager?) can install a modprobe.conf file to override
> > that once it can handle MBIM.  We handled KMS transitions in a similar
> > way.  I don't know that it's worth having a Kconfig option for that,
> > though.
>=20
> We could consider always defaulting to NCM.  That would remove the
> ugliest parts of the code as well.  Should I send a new version with
> such a change?

We could, but I fear that would annoy people building custom kernels.

> Bundling a modprobe.conf file to enable MBIM with userland tools
> supporting it is a great idea, and sounds feasible for custom built
> systems as well.

Using unpatched Linux & ModemManager (or other userland) needs to just
work.  So if Linux is going to have MBIM disabled by default then
upstream ModemManager needs to ship and install that modprobe.conf file.

> (BTW, if there is any doubt about it, I feel really bad about my recent
> request to enable MBIM in Debian, where I wrote "enabling the driver
> will not prevent any existing solution from working.".  At the time, I
> had not seen any of these dual NCM/MBIM functions and I just didn't
> think about the problems such devices would run into. Sorry about
> that. I guess I owe you one more...)

It's called experimental for a reason. :-)

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-vpYt+ITSaAWfAYBqQ/o2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUUSxGee/yOyVhhEJAQr+8w/+OX7Pxl/qgHm+Nqbd+btuJDGYJgdVULL2
4XtSNWhDVIiqf4P8ZtCoqwkIzpsawGW85WsGWNoW9VcVY+blSdmZQGxI2I1mjVAS
OrqxCIVHg30n+LylqqopFDCbtk4c2/5FlEv4n1Y9vpdTfm8O73eOQgXSDsGIGlm3
DCAWsGz6IlW7xe2FyF9YEAqqXhPH4p0oea1kADtrSUW1e/hMx3D5A6pc47bRwEYS
pg05XqGnrPTuHK9XydWrxQT6wWsHYfe2eGCTSpEFeXJ9SE/a+2L3ucH3uT+83opK
7aYjc2RliLokEGjKQjEGSneIUHsp7pF24tXIkwJn19DH/xYuBwl19NyWJVjExVI3
UBYemQDyfl7q/q6+lA36n4J4NNM9/iwpZY6rtXJ7Sg/a9Y/LfiiZRUm8l1NhRh6G
4MDOPC3X84CLV8vvQuX/1QifN/RGtQyPs1VFWlJgp2TFRNURf5DL9+JwB7IU+pT5
osFsKFwnrlTqsj+INPrVpbE9QBzDZAwcaf/ufNc7Xf/AtxjLkBq3YLJ1YMNstUTd
bfp1uk5uEph8cW7Q0wlv1fX/3v9AMNvm5YeQ6bivIhdIWLhM1fHDVzJLjqVZ1R80
0mqZhxLdLUbq48rSTKn9tOErQOV5MxhG56eEORloWvatHtJsQZYpEKXly5tuNQCr
Q9imU7ofRJY=
=1Vk/
-----END PGP SIGNATURE-----

--=-vpYt+ITSaAWfAYBqQ/o2--
