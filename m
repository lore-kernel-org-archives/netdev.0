From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] igb: don't unmap hw_addr if its NULL
Date: Thu, 10 Sep 2015 17:55:54 +0000
Message-ID: <9AC147AD-6D52-4A7D-BE5B-3A40F8D22B1A@intel.com>
References: <1441858049-44827-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_FC1FB1F5-D217-4D65-99D8-8A02A975EC80";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441858049-44827-1-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_FC1FB1F5-D217-4D65-99D8-8A02A975EC80
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 9, 2015, at 9:07 PM, Jarod Wilson <jarod@redhat.com> wrote:
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c =
b/drivers/net/ethernet/intel/igb/igb_main.c
> index e174fbb..a5e0022 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2823,7 +2823,8 @@ static void igb_remove(struct pci_dev *pdev)
>=20
> 	igb_clear_interrupt_scheme(adapter);
>=20
> -	pci_iounmap(pdev, hw->hw_addr);
> +	if (hw->hw_addr)
> +		pci_iounmap(pdev, hw->hw_addr);
> 	if (hw->flash_address)
> 		iounmap(hw->flash_address);
> 	pci_release_selected_regions(pdev,

I don't think that this is entirely the right solution. In ixgbe we have =
a separate pointer, io_addr, used to manage the resource, so that the =
space can be freed even after hw_addr is cleared. With the approach =
above, the pci_iounmap will not ever be called on the space. You can see =
how ixgbe is doing it.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_FC1FB1F5-D217-4D65-99D8-8A02A975EC80
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV8cQqAAoJEDwO/+eO4+5ukCgP/i8nBcMjNnlyRogsstonwblL
dB7Go6zBcyTPka2/k9fwLQu0zDzaImEo6CbsZWOQkClnaCXts4wlaamfWQ2BX6Hr
Miq+GTu3lCDd6Tnv6+YIovoIrP5P/0/x1TpAxVmhuYk2uJUEH4jNwRa7nOcc3RCH
wpPHl8ffAXdASIwBhMgy4trWCxD417Z7dYbqs3PB+darzGXYE5IuyCKGgN2KG1hY
xgGXa3C7rOwMBNGA/Wq5EyC5B3j6jBH9U5kWVFa9t6Z9CFjSkqm2dJCAXv37EzxQ
xIPgxil3Tmj2ds9AgArQ6fy/4QT7u6bfc3Dk62mKeHPU/tc4pdB9GkIjIEvyrCjf
Pg+W3IFbEB6Q104W484qURw1b8d4Sl2t0+cj/BYI31EhjyOyXLsVZh99VVcy9myG
zyCfg4vQ/HsHJ2tz6wVitR/uXph89KaXIAgxUotlCZZ6gv6ExV+zlC/2tPL+3sph
G1W1g68TRST/0sKWAd7P8Ji1qud+8tXt6Bqf8Xs1uYOo1992gJkbBdJocjMqWoui
8i9OQwwpEl5RbKoqqeEIggmD7F3OjBlJRHnoTRjVwUJo8fR3J5//yM0rzF6/uTAE
HmXgYb7dmsepqp1CbgjUduLQajnTbfMIsUGTprC+WqejUc7GvUAIzqiKX5U3C+eI
2JqvubbXxv4SeoEO/qRA
=dojk
-----END PGP SIGNATURE-----

--Apple-Mail=_FC1FB1F5-D217-4D65-99D8-8A02A975EC80--
