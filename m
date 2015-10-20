From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] fm10k:Fix error handling in the
 function	fm10k_setup_tc
Date: Tue, 20 Oct 2015 23:11:51 +0000
Message-ID: <6C4F5FD8-58B6-4A4D-8EAF-A02C3DB64560@intel.com>
References: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_46269F50-C5C6-4A6D-B129-1A2EB3F6857A";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30213 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695AbbJTXL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 19:11:58 -0400
In-Reply-To: <1445375114-13378-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_46269F50-C5C6-4A6D-B129-1A2EB3F6857A
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Nicholas Krause <xerofoify@gmail.com> wrote:

> This fixes error handling in the function fm10k_setup_tc to properly
> check if the call to the function fm10k_open has failed by returning
> a error and if so return immediately to the caller of the function
> fm10k_setup_tc to properly signal this non recoverable failure.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c =
b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> index 99228bf..5a4e702 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> @@ -1146,6 +1146,7 @@ static struct rtnl_link_stats64 =
*fm10k_get_stats64(struct net_device *netdev,
> int fm10k_setup_tc(struct net_device *dev, u8 tc)
> {
> 	struct fm10k_intfc *interface =3D netdev_priv(dev);
> +	int err;
>=20
> 	/* Currently only the PF supports priority classes */
> 	if (tc && (interface->hw.mac.type !=3D fm10k_mac_pf))
> @@ -1175,7 +1176,9 @@ int fm10k_setup_tc(struct net_device *dev, u8 =
tc)
> 	fm10k_mbx_request_irq(interface);
>=20
> 	if (netif_running(dev))
> -		fm10k_open(dev);
> +		err =3D fm10k_open(dev);
> +	if (err)
> +		return err;
>=20
> 	/* flag to indicate SWPRI has yet to be updated */
> 	interface->flags |=3D FM10K_FLAG_SWPRI_CONFIG;

NAK. This will reference an uninitialized err variable when =
netif_running returns false. The compiler should complain about this, =
suggesting that it wasn't compiled.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_46269F50-C5C6-4A6D-B129-1A2EB3F6857A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWJso2AAoJEDwO/+eO4+5ulwgQALm11lsxGKKEmKzuFoUYlLlu
9UfnlumP/qQJtrs/gKYC8UXT++2xykvabqUM5/9lHpxXmDBJBIyMy1QjvD+IDs5r
+W86TLGUTdRtPwToIoiCfstjUKLJWobKm8rcG9q7WC1hOqTu6+3fRTlke82572r4
39N9IQZ5eu1UtdQ1aJO89aOYx8xx4hq7IjuD+QC37y2e5mmGOjvnsnC0X1ZP5jb3
l7AFNvoVpaskVbiSfiddG0rXhyJHpUSHzZuYVpgos/ZPOtfu5KtA7J/99OysTOeu
eXOjJHO/ma8Mwp6obfWeOVVKBG+dRZBWDtahl6IpoKSO2IsTSWVPbdDlnY9OXrmz
2f/UgZDIe7C5wAdhv2d0LDMSCjhmyZs28nB1B6i7d6DO861nfADE7tBeBOkxwu3u
gU+EbjdwKmBFzB1W+qwxDFBSW+Cz2RFC39E3eb4uZX5mLlT9w//uSQoLaV3ZFbRM
OmLDURrXYJu1U/XuttwumMn/u4Ru1m6RUogH/c+qwkU7UbgR4es8lP6IxYvFpc/Q
CYybSblbL628qW5j30b8y6s1VKn0oS6YKYGK87xy0+xbYVJxkqXjLXo0qI+Uj1gU
VKIAQ8su/Vubhs4DdpPqKCutCrfYfwOQM6LfdsjZ60y1sR6JRItMQI/6jhso41VR
KdhgimrR13npF0a0ju0c
=tw7H
-----END PGP SIGNATURE-----

--Apple-Mail=_46269F50-C5C6-4A6D-B129-1A2EB3F6857A--
