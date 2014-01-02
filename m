From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 2 Jan 2014 19:06:32 +0000
Message-ID: <E5031C0F-8B35-477A-842F-33CDBA98C097@intel.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1388686871.9947.20.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4ABA425F-A606-432A-B01C-FB303916F369";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2888 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782AbaABTGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 14:06:34 -0500
In-Reply-To: <1388686871.9947.20.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_4ABA425F-A606-432A-B01C-FB303916F369
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

On Jan 2, 2014, at 10:21 AM, Ben Hutchings <bhutchings@solarflare.com> =
wrote:

> On Thu, 2014-01-02 at 01:33 -0800, Jeff Kirsher wrote:
>> This series contains updates to ixgbe, e1000e and igb.
>>=20
>> Most notably is Mark Rustad's ixgbe patches to add the Live Error
>> Recovery option to ixgbe as well as additional cleanups to the =
driver.
> [...]
>=20
> The Live Error Recovery option is pretty odd; it looks like a
> combination of PCI hotplug and EEH.  Why is it not integrated with
> either of those?

It certainly is related to both of those. The issue being addressed here =
is specific to this driver in that the driver can be the first to get a =
read return of all one=92s when a device is suddenly removed. This code =
allows the driver to determine whether such a return is valid, or is a =
sign of the device having been removed. Without those checks, there are =
paths where the driver will crash in such a case. This code will race =
with hotplug, so it allows hotplug to drive the logical removal, but it =
makes the driver =93safe=94 in the mean time.

Thanks for the comments. You are absolutely right about the need for =
ACCESS_ONCE and better Kconfig help text.

> Ben.
>=20
> --=20
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_4ABA425F-A606-432A-B01C-FB303916F369
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSxbi2AAoJEDwO/+eO4+5uUScP/1ZNBMEoGh90/TN3g+U7y/t3
ZtNRQ19xLC4VOL1K/NwCzLLHPXxTslCZLmES3alBQXI/upyjm20L1L+zjaOYxPRF
0k39cJTspdNusgvMbodrxuxvE12mGEUvrZwTvKiOpWa3J+xfsPrfI9tfnWb8ibGY
QH63LkbAxjdbMINMiN5AOgoA7AJgwiNwDRyiNDdlZZrXYaOeCKpWlcSCpJaCswkm
OasOlQ5KKfA2xo6OAtOXDJkI+bqc89VffiYSnH4kg45G13qyKGidi7kTGLox6IBb
B1y8FqCHV6qKbzbc5rdpJAZRTJLMrHk6hB9wNZ6S7YjfQdRqTmDr3PoCAILDH5MH
9bl72hPrEc1R/5k2uvZI+0nnihVuNWJLzID396gkaQWGNslaGgCmOYZEQ3OAFg1W
/hmFZLxupvYqjBv1qSc+fDDlMkQTUmuSGwDcEaeDb18rEL49Mo1xEhFqH0mYLtx+
VhPyz1BoE6yzNXXDjonKeFksQ7uuk1+roIapjRtGAr6TB7l0E5Tys/KgKzVV1DJF
zXYEioB2zllvrKKKIJJyiBuPfdg2KEHHn5N1GslaQLoo/KwfktiBmH2VYF3dQ6Lt
WL4r+/+dVC8pTCA4qqlL/Kd/GbzXRbmo4+mJJ0bX19vb8O9t2V1PYfwDh7NFdE0B
jF9LFxH5SL0SF0FVhc4V
=dsdk
-----END PGP SIGNATURE-----

--Apple-Mail=_4ABA425F-A606-432A-B01C-FB303916F369--
