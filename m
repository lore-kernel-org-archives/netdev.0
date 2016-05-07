From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for
 get_coalesce, set_coalesce ethtool operations
Date: Sat, 07 May 2016 13:04:46 +0100
Message-ID: <1462622686.19332.33.camel@decadent.org.uk>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>
	 <1462576336-83513-6-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XRxruTvPAyi8dKiwM7GR"
Cc: Keyong Sun <sunk@vmware.com>, Manoj Tammali <tammalim@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462576336-83513-6-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XRxruTvPAyi8dKiwM7GR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-05-06 at 16:12 -0700, Shrikrishna Khare wrote:
[...]
> +static int
> +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ec)
> +{
[...]
> +	switch (ec->rx_coalesce_usecs) {
> +	case VMXNET3_COALESCE_DEFAULT:
> +	case VMXNET3_COALESCE_DISABLED:
> +	case VMXNET3_COALESCE_ADAPT:
> +		if (ec->tx_max_coalesced_frames ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_irq ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_irq) {
> +			return -EINVAL;
> +		}
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D ec->rx_coalesce_usecs;
> +		break;
> +	case VMXNET3_COALESCE_STATIC:
[...]

I don't want to see drivers introducing magic values for fields that
are denominated in microseconds (especially not for 0, which is the
correct way to specify 'no coalescing'). =C2=A0If the current
ethtool_coalesce structure is inadequate, propose an extension.

Ben.

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999
--=-XRxruTvPAyi8dKiwM7GR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXLdneAAoJEOe/yOyVhhEJNa4P/RxBk75w+vL+rqIQyDa1TJx8
O6BqSMvvbDnFDQRCYG1fKYtJoyAYOEua5VPyzXg4GCeNqAL8qBjWIkbDFb9kipVm
TumbSKrSo5Jnr5ZoDtgDHi094wyFcXoL0gu+MXZ2UbVMVFjFeovZj4irKWS3PVYN
4u5XPOs8mNqe9JWbyxsYYZ9ANW33egC8GN/ub5ErofpgGMnYSUPzkk060QEgD3cd
tysZ4y/7miuLmdRz965YAwxh5BNT0i3/LTwoTIqbgUrFMOZpZ2CaTwJO4DacHFYm
EDyfJrkqSmEzjv2QmSVUuSqq0ei+g3iYGtRHKHCpJIL0DV5dnJ9OzxQMWjzQs0X1
tELmzK18awDInK2kUKb/TKomD08HZZKC7jzmOb8l1cA8zHdK2FVq59keWitCc6pS
3JOgmdqqPNhMbFrrmvTAOP7TA2RF75RFBoOPsOq9pQb8erk0AC4FDXBlG60ne+Ke
rEDYLTjNCG2slan7d0DCmrS645PipByjk3JrVXHEhTdC7BBVeYt+ajI2vkleXhyc
GgWY3gNckCsg4/eupzT4oVsuhmXsI4iMJTsGMipf5FMqyN46pX65HDKAE9mfB1BV
jocyEXoJBMklqebPgEKe2HXyBTnacqIl2Lig+bjOiJJ4O+2Up+ZrOiXsGx8ADMik
0rKt1aPN9h0afO3AH4b5
=zVrR
-----END PGP SIGNATURE-----

--=-XRxruTvPAyi8dKiwM7GR--
