From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
 2015-09-28
Date: Mon, 28 Sep 2015 17:33:54 -0700
Message-ID: <1443486834.2864.1.camel@intel.com>
References: <1443468800-37102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-y8OiL14+OldNjWAnr+Jd"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46540 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457AbbI2Afn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:35:43 -0400
In-Reply-To: <1443468800-37102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y8OiL14+OldNjWAnr+Jd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-09-28 at 12:33 -0700, Jeff Kirsher wrote:
> This series contains updates to i40e, i40evf and igb to resolve
> issues
> seen and reported by Red Hat.
>=20
> Kiran moves i40e_get_head() in preparation for the refactor of the Tx
> timeout logic, so that it can be used in other areas of the driver.
> Refactored the driver timeout logic by issuing a writeback request
> via
> a software interrupt to the hardware the first time the driver
> detects
> a hang.  This was due to the driver being too aggressive in resetting
> a
> hung queue.
>=20
> Shannon adds the GRE protocol to the transmit checksum encoding.
>=20
> Anjali fixes an issue of forcing writeback too often, which caused us
> to
> not benefit from NAPI.  We now disable force writeback in the clean
> routine for X710 and XL710 adapters.  The X722 adapters do not enable
> interrupt to force a writeback and benefit from WB_ON_ITR and so
> force
> WB is left enabled for those adapters.
>=20
> Stefan Assmann provides a fix for igb where SR-IOV was not getting
> enabled properly and we ran into a NULL pointer if the max_vfs module
> parameter is specified.  This is prevented by setting the
> IGB_FLAG_HAS_MSIX bit before calling igb_probe_vfs().
>=20
> The following are changes since commit
> 34c2d9fb0498c066afbe610b15e18995fd8be792:
>   bridge: Allow forward delay to be cfgd when STP enabled
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
> master

I need to add one more patch to this series from Anjali which resolves
a possible deadlock issue.  So v2 of the series is coming shortly.
--=-y8OiL14+OldNjWAnr+Jd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWCdxyAAoJEOVv75VaS+3OfhAP/jBgn3uIzirCd+PIEBiXreqE
X2O+QBcoZgHtap/AtWmmYRScAr0HNbq1CFwIRTU+31/RDn1QFJOFKxHoaJeDclHD
WFgxdc2CvDzIWg2SrfFk5gAUzWON9if6joE8jVzEALRTHAS1GI7Xc9WBZsJa+mVF
vMMvTRTGqqBvGYFz4N9MmMRYag9TVWYiitBYB/xtktKOVZ57wFS/6VkZQQE7HMtX
odT9oXOzEI9UmY1nUOUF9D1p1+MKzHfpETRymcWr3lQOYdedhNdn04BQAQbtX2sc
bUgZZdMwYZ1pFoKmcFFCNzBmnWAuPk0zfpdS8lCN3uaHzYnpt4/S3xrjDf+Q6d5a
j6Kk81thG5bi/16DHhQGSPXSUyIDX4dcS4uwPcEHUdKBR7RefHJDXVEsyMEllvdy
E4cBkW1tgMXxD2prlsB5dhtdBbW5X0efpl39GPhSa2UooYNWTJrK2YcpJc+cuuT4
0yXn/z9AuMjNB9OA+o9QVjgaTCAm0FreJ3SAgT/PkCy6XRQeFk4myh1ut/gq2l3/
ZmGfpqiWkNbJvsaTZAk6SkCR90sLKTl6plvV3Z/SRnQAuCJcS/qKJITQJxxEfKtD
8nlWFI7IVoQAWpVGUJr1dSt31bgf/6SGcIfy3asr4oc8dX4D2rUm1CVUSEt6Diy6
tzFMKdgS6MZULBPgINHo
=BJkA
-----END PGP SIGNATURE-----

--=-y8OiL14+OldNjWAnr+Jd--
