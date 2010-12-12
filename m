From: Ben Hutchings <benh@debian.org>
Subject: Re: [PATCH v2] net/r8169: Remove the firmware of RTL8111D
Date: Sun, 12 Dec 2010 04:25:59 +0000
Message-ID: <1292127959.3136.272.camel@localhost>
References: <1291619474-3244-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-4AFJPI6FkkeNcNHco4AA"
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51805 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750854Ab0LLE0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 23:26:05 -0500
In-Reply-To: <1291619474-3244-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4AFJPI6FkkeNcNHco4AA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-12-07 at 15:19 +0000, Hayes Wang wrote:
> Remove the firmware of RTL8111D from the kernel.
> The binary file of firmware would be moved to linux-firmware repository.
> The firmwares are rtl_nic/rtl8168d-1.fw and rtl_nic/rtl8168d-2.fw.
> The driver would load the firmware through request_firmware. The driver
> would just go along if the firmware couldn't be found. However, it is
> suggested to be done with the suitable firmware.
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |  796 ++++++++-------------------------------------=
------
>  1 files changed, 117 insertions(+), 679 deletions(-)
>  mode change 100644 =3D> 100755 drivers/net/r8169.c
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> old mode 100644
> new mode 100755

Please do not make source files executable.

> index 7d33ef4..e0df607
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> +static void
> +rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
> +{
> +	void __iomem *ioaddr =3D tp->mmio_addr;
> +	u32 *phytable =3D (u32 *)fw->data;

This line should use __le32 not u32 to make it clearer which byte order
is being used.

> +	u32 action;
> +	size_t len =3D fw->size / sizeof(*phytable);
> +	u32 regno, data;
> +
> +	while (len-- > 0 && *phytable !=3D 0) {
> +		action =3D le32_to_cpu(*phytable);
> +		regno =3D (action & 0x0FFF0000) >> 16;
> +		data =3D action & 0x0000FFFF;
> +
> +		switch(action & 0xF0000000) {
> +		case PHY_WRITE:
> +			mdio_write(ioaddr, regno, data);
> +			phytable++;
> +			break;
> +		default:
> +			netif_err(tp, probe, tp->dev,
> +				  "Unknown action 0x%08x\n", action);
> +			return;
> +		}
> +	}
[...]

I think should validate the action types before starting.  Otherwise it
could begin loading the firmware and then abort (without even returning
an error code) which would be worse than not loading it at all.

Other than that, this is good, especially the addition of comments for
some of the register initialisation sequences.

Ben.

--=20
Ben Hutchings, Debian Developer and kernel team member


--=-4AFJPI6FkkeNcNHco4AA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATQRO0ue/yOyVhhEJAQINLxAAoIONiR5ej4R551LbYMU6itSpXArv6JnO
t+R9ZEBMC/QMhqL2j6VZgUmbySarw0dB15s4g3CaOoim/TnXr7ipM8igT7SJyPt+
kp/CrBfpjepu7ANoarRJ++de9O7KimTX9bLMFBZUco/5QsUtGSHhf7ukEZBQI8+Z
KEF3x+Ogy+QpCvp+UW6sfa+zJUtl7V00KOPq1e8Qkqv9vJnDIFEyHnkaUGAILNQq
JuxQOdeaO47NbDn7Os/GiprrvtpLmT+4wZY/5Cg1hTbIEk/OybXx5OmmTW+wzjmz
EEO2xQjdsiupkFPHRzwVuERWPqDu96jj8TWHl5ClPku38Y8V4bZJwpOFdT3JDj6g
qHFf1b9t3+s5mNtM7xy31TWjfsYaPxMJYcwMgqdqBv8lyPj1v8cy+7fZpNhnMQfw
/OmleUc+S2wZPRpoWIuoY1LaLomLWHEuNW3QAY5/YuKFcGLp/27OMChEF/ZgvrK4
/s/Ko6jpMpvASHEg81kjKeAeBQv1xmFd6kJZ+6i6KyUQf2m4WuimojdszV/Jx6aB
vRVnJJKq0Tr59B5y9YsG3l0mKMrhkkIS3Ov14dTR5pkDyw5zX/dXnqyjBuiQmQ5H
n+nWLE+hSW+QVVOfZ++fPpkcaMvEGdQvKcuMjAgRwhLZZzlnN7Tw0Jxy0fl84n39
FRMWtNe8zco=
=kX3i
-----END PGP SIGNATURE-----

--=-4AFJPI6FkkeNcNHco4AA--
