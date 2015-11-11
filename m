From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] regression in ixgbe SFP detection patch
Date: Wed, 11 Nov 2015 22:13:48 +0000
Message-ID: <424516AF-C3E7-4D00-8889-ED7EA8EF315E@intel.com>
References: <20151111173527.GA3641@gandi.net>
 <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D9B2A707-1A10-4DCD-8B90-3EA4E4E5B0E8";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: William Dauchy <william@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18526 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbbKKWOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 17:14:10 -0500
In-Reply-To: <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_D9B2A707-1A10-4DCD-8B90-3EA4E4E5B0E8
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

William,

Emil S <emil.s.tantilov@intel.com> wrote:

>> It also fixes my issue: even if eth{2,3} are still up with no =
carrier, I
>> don't have any kworker in D state.
>=20
> It appears that you have 2 ports with empty cages. If that is the case =
there
> is no reason to keep the interfaces up. If you bring them down, or =
plug the SFP+
> modules the kworkers should stop.
>=20
>> So, is it something we should consider as a regression, in that case =
I
>> can send a formal patch, or do you need some more information to help
>> you debug it?
>=20
> If the diff above is the patch you are referring to then you will =
break the
> SFP+ detection in the case where the driver was loaded while there =
were no
> SFP+ modules present in the cages.

Just so you know, there are patches in queue that will improve this =
situation in two ways:

1) When the I2C probe times out, the code assumes that the cage is empty =
and does not retry the access until the next probe.

2) The driver will use its own private workqueue, so it will not affect =
the system workqueues at all.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_D9B2A707-1A10-4DCD-8B90-3EA4E4E5B0E8
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWQ72cAAoJEDwO/+eO4+5uFMQP/2DZ7hAHAE66IeyFMewcWEj7
TB7TFgP+15D03xhFnWeagpN3efsf/4PZ60iIBtxuVVMOgZPXXqPuxxjdHI2ew9A3
jRWThqfpsuQOQY/8bl88deCeO8BWOXaSdSLEyhVyiut5+Oc/hfj03JZ9NK/WDhzq
9Xmcmq4P9fOH+SogsPBfegg2shoO6Kku6iSbgfZ4z1RTQEsQas4xR97dI7zlOddb
ymF5zF0NO22XHbj2qSVgD5ZR0xhtiz6IhH/vqKGmovfxmhxtRjJLsveYMVENBv9Z
po+rs5moVp6RcWuCoqjWvf7aPG19VoYjTMMZA39uI31eUIlGqAM4Jc57GzYwNCNV
tPEL1l0rXqmxDj7bSeO/PiCEcG0H2zI9UW96nWUuYKDqCk7JXYCfGRf5YgBcKkat
srbq8faGYMP8W489yqhU+NNDJviTcYz7ABnuVQEDmMv/yGCN0N3AyTwJL6uHGrB+
Pd3/ZsJMXIBYvhQClrNI6825a9cV/2MU+NiXJY3xYTu6XSE+8951M8yicO5h5DB+
h4DzeYR7TKLkaiNURgx+QyFaYgfGfrf0pfHxl/wBQj/IIjyCjXfDsMlt2FhFqGEf
5sgPFIhEtJ0VWS8/At8sToDIFpYU0kpc0jxdvObp8gOWRhjXN5cWPgDo5A593+dU
t4l+zsS2jyh6zboIsgKN
=5tIn
-----END PGP SIGNATURE-----

--Apple-Mail=_D9B2A707-1A10-4DCD-8B90-3EA4E4E5B0E8--
