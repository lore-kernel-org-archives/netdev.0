From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] netxen: memory corruption by netxen_p3_get_mac_addr.
Date: Sat, 3 Mar 2012 21:35:38 +0300
Message-ID: <20120303183538.GZ1003@mwanda>
References: <1330794087-19248-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E0GpUEom8qu4+vDz"
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dhananjay Phadke <dhananjay@netxen.com>,
	kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330794087-19248-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--E0GpUEom8qu4+vDz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Mar 03, 2012 at 10:31:27PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>=20
> 'mac_hi' and 'mac_lo' are 32 bit unsinged int but we are modifing
> 64 bit of memory during mac calculation. To fix this issue define
> a local variable of 64 bit and do mac calculation.
>=20

I'm not seeing any memory corruption.  How do you figure?

> Remove 'le64_to_cpu' to fix endian issue.

I've add Dhananjay to the CC list to comment on the endian change.

regards,
dan carpenter

>=20
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers=
/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> index 0f81287..7ea930b 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> @@ -1069,7 +1069,8 @@ int netxen_get_flash_mac_addr(struct netxen_adapter=
 *adapter, u64 *mac)
> =20
>  int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac)
>  {
> -	uint32_t crbaddr, mac_hi, mac_lo;
> +	uint32_t crbaddr;
> +	u64 mac_hi, mac_lo;
>  	int pci_func =3D adapter->ahw.pci_func;
> =20
>  	crbaddr =3D CRB_MAC_BLOCK_START +
> @@ -1079,9 +1080,9 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *a=
dapter, u64 *mac)
>  	mac_hi =3D NXRD32(adapter, crbaddr+4);
> =20
>  	if (pci_func & 1)
> -		*mac =3D le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
> +		*mac =3D (mac_lo >> 16) | (mac_hi << 16);
>  	else
> -		*mac =3D le64_to_cpu((u64)mac_lo | ((u64)mac_hi << 32));
> +		*mac =3D mac_lo | (mac_hi << 32);
> =20
>  	return 0;
>  }
> --=20
> 1.7.4.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors=
" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--E0GpUEom8qu4+vDz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPUmR5AAoJEOnZkXI/YHqR8SYQALLawwJENBtjKAU0BpLniTUn
c8gp5A59k5lwgq9848ZubgGeA/IU0SBAafgka9l3jh5yd+4OeeXSxvttrv+l4IdS
WUWSXnJbcSW6XcUN+DOx+CADh1YibC2Dm+jlhLSSqbLkXj6Qr2bgWOr5bUwNvzlA
wO+Bu+0gycwBmu3ZKnc4JpQPFTWa9vjtqGNEoox6SySggcHIvOJ0XCkBrG2XY7SN
j6uJuB40sXOAXqR2IokOMa4uFoPNWcFhZkLq/SqxnabD93Ne83Fdll994v0XQNmm
Gc1BUvDJEZSwsxZWKL0257hQ4m6XDLhroVTlkXhPiImvWoEz2ceKgUr2d3VEQfPA
hLKc1fUmTvk77C6Py/N4Nt3vDJqfyBSQi4JAXYfigz0NEw74o7ZRL0vAITBAsa0o
59VRU8NqjxvzZJPQLDWof91Tb69koPg0iGSnG7W6BMM1dJV1b4DWSRb9d0HoFodf
KLKEo1J8hV6b1/BZZdPujzTR+qyC4NXTs1n7viqxmNhEdjhZmbMhvrxUWkgBWvyx
ELK1CIiat2I/7SXwROwfeH/jLNGSlozEg5uybVhndJVsiEk2M7NK54CI01spc+5A
1Sg16McyMfxPZk2bJ4mBshyPn77Bk+FkPquIKFfeOvdqKhS2VmJeRt1LBAMfMCwC
O3GvXqgTPDpaV7siU4nT
=lRRn
-----END PGP SIGNATURE-----

--E0GpUEom8qu4+vDz--
