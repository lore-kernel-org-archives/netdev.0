From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 04/15] i40e: remove BUG_ON from feature string
 building
Date: Tue, 01 Dec 2015 23:25:00 -0800
Message-ID: <1449041100.3224.17.camel@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
	 <1448480194.20113.48.camel@perches.com>
	 <1449002936.1593.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nMC4nkYEf0l6URGmAKre"
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John Ronciak <john.ronciak@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Joe Perches <joe@perches.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37880 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbbLBHZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 02:25:02 -0500
In-Reply-To: <1449002936.1593.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nMC4nkYEf0l6URGmAKre
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-12-01 at 12:48 -0800, Joe Perches wrote:
> On Wed, 2015-11-25 at 11:36 -0800, Joe Perches wrote:
> > On Wed, 2015-11-25 at 10:35 -0800, Jeff Kirsher wrote:
> > > On Wed, 2015-11-25 at 21:26 +0300, Sergei Shtylyov wrote:
> > > > On 11/25/2015 09:21 PM, Jeff Kirsher wrote:
> > > >=20
> > > > > From: Shannon Nelson <shannon.nelson@intel.com>
> > > > >=20
> > > > > There's really no reason to kill the kernel thread just
> because
> > > > > of a
> > > > > little info string. This reworks the code to use snprintf's
> > > > > limiting to
> > > > > assure that the string is never too long, and WARN_ON to
> still
> > > > > put out
> > > > > a warning that we might want to look at the feature list
> > > > > length.
> > > > >=20
> > > > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > > > > b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > []
> > > > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (pf->flags & I40E_FL=
AG_VEB_MODE_ENABLED)
> > > > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 buf +=3D sprintf(buf, "VEB ");
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 i +=3D snprintf(&buf[i], REMAIN(i), "VEPA ");
> > > >=20
> > > >=C2=A0=C2=A0=C2=A0=C2=A0 Not "VEB "?
> > >=20
> > > Nice catch Sergei, I will wait a till this afternoon to respin
> the
> > > patch series, just in case there are other changes needed that
> our
> > > validation did not catch. :-)
> >=20
> > trivia:
> >=20
> > If you redo these, it'd be nicer not to use " " after each
> > fixed string, but use " " before each fixed string.
> >=20
> > The final output string would be 1 byte shorter overall and
> > not have an excess " " before the newline.
> >=20
> > The declaration of i doesn't need initialization to 0:
> >=20
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i =3D snprintf(buf, INFO_STRIN=
G_LEN, "Features: PF-id[%d]", ...
> >=20
> > would work.
>=20
> Maybe something like this patch (net-next)
>=20
> Fix I40E_FLAG_VEB_MODE_ENABLED output of VEB
>=20
> Miscellanea:
> o Remove unnecessary string variable
> o Add space before not after fixed strings
> o Use kmalloc not kzalloc
> o Don't initialize i to 0, use result of first snprintf
>=20
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++----
> ------------
> =C2=A01 file changed, 19 insertions(+), 23 deletions(-)

Looks fine Joe, can you send to intel-wired-lan@lists.osuosl.org=C2=A0maili=
n
g list? =C2=A0That way I can get it added to my queue and the other
developers can properly review the change.
--=-nMC4nkYEf0l6URGmAKre
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWXpzMAAoJEOVv75VaS+3OaZEP/1VQbYjWwMEXzLLo4jiqy+8U
k1PpD/Dvu1vIyiWUlsPWWaQwFa3D1W57QVq2NHkfpjubyhhyVjEY7f4oWMq0WqoH
8pDFZyh/p0aEjRKtSTqFtxRgoHYL7KNm/swG4EwWQF3JCEBBonmKpr7zL0QcpfK4
yrE+kTYxFri2DdFKY5s32lC3XW7d6KCH87pFTN1d9KLA0zCJQoOCTlAPftwG9TBL
Z/lX/cVFN+HtRxCOrIxIfNl17jAkp7qHLmaSMD0Jpj7FbZdPOLfk2vvitV3Vehmz
rNN5VLsOfnylz3O9K27szHn8I0AQ5xadGHI4x5WSCNdFMD2r0kqcWeBe+KYRwP+e
65+wC/zPgLxgtGMix/tM7ZrSxGbnOol7xc69M42s4KV7vnzbfP26Rw6QN+XgHsXn
fChduOZW3dFiT2RYDBMnljRLas/mg/3GhwIZ3ersT+ZajtK6QoWzLsd6dnIDAIMu
tPpnNqOIPWqfPjiykQST2f5E7DvLVWnzrJYydVzGnWeJTfORrrJZ6+4T3O1V9cDg
9kF8JalBHPbHtTfYTkVCbZJ6LQYS3ypJLmUDTqK7BULjsFhR8YXSmEx5czOkZWlv
IyJNBoZjVT3XMTGRKhAKBc/TlapZ9p00PDuSJRXlbcoCjHOTZL7vP3NAPJYv+aRX
jlA4avdVrg2KUNKweaCH
=XnV7
-----END PGP SIGNATURE-----

--=-nMC4nkYEf0l6URGmAKre--
