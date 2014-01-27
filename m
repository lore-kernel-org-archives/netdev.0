From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Mon, 27 Jan 2014 14:57:34 +0000
Message-ID: <1390834654.2735.148.camel@deadeye.wl.decadent.org.uk>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-4-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0zul8nVdeMz661fyLdCf"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390823503-24087-4-git-send-email-alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-0zul8nVdeMz661fyLdCf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 15:51 +0400, Alexey Charkov wrote:
> This should make the driver usable with VIA/WonderMedia ARM-based
> Systems-on-Chip integrated Rhine III adapters. Note that these
> are always in MMIO mode, and don't have any known EEPROM.
[...]
> --- a/drivers/net/ethernet/via/Kconfig
> +++ b/drivers/net/ethernet/via/Kconfig
> @@ -19,7 +19,7 @@ if NET_VENDOR_VIA
> =20
>  config VIA_RHINE
>         tristate "VIA Rhine support"
> -       depends on PCI
> +       depends on (PCI || USE_OF)
>         select CRC32
>         select MII
>         ---help---

This seems like the right thing to do, but it means you need to add
#ifdef CONFIG_PCI and #ifdef CONFIG_USE_OF around the driver structures
and related functions.

You should compile-test in configurations that have just one of those
dependencies enabled.

[...]
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
[...]
> @@ -847,7 +856,8 @@ static void rhine_hw_init(struct net_device *dev, lon=
g pioaddr)
>  		msleep(5);
> =20
>  	/* Reload EEPROM controlled bytes cleared by soft reset */
> -	rhine_reload_eeprom(pioaddr, dev);
> +	if (!strncmp(dev->dev.parent->bus->name, "pci", 3))
> +		rhine_reload_eeprom(pioaddr, dev);
[...]

Ew.  I think you should use dev_is_pci(), although you might also need
to guard that with #ifdef CONFIG_PCI.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-0zul8nVdeMz661fyLdCf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuZz3ue/yOyVhhEJAQoomRAA1oBECLtbT/EgIpt2b7ITfE6jk29iHmgK
RS7Fq3vqWCTCZcNE2zNOXpjF7HYkGPNG0hUChGcxGAVdkW6A/jcMKGD+LYf00KOb
YSSpwT9H7fXa07/6OAnx9F/kQ7dAkY8ntiWTN4gVUwNfy7x/e3umu/+8u+wOZJzE
5SszaLdNMagluTV6Yy5/2qL8JzS2IdB0veyz+ZYHDGLOweB5UkwiH/nSvtSDkEqg
92xEBeDyh85r0w/AcOsNBAY/0NbTBoHTKx8yfZLZn25Xj4Xre8P5CV9aqYUVSRoC
GdDYAjPtwknX2/+tZAUf3O+PqFUnxfpFsP+f7Dd8JsdK6rd7u5z/CIKl0SAMRiZe
y+tM6Nzcw+YQmfZlZhG5PM0LmMR2PBz+Yzdgs/jttRxVEZlTXxiynKwl4gcNi9W/
0QAMMVYB7hfQYUmpWNQYtibBHn6PVvxhG9YuVT2yP4IABuUYeF0ZJuoQngv2FrRK
BdD0kVHAVosws3JBhIYQIKRCeWEAaaQGYA2v5nnbAUpO/MV7EBMPMfo3m62jgWXH
M32EHH8ESX1CzD0OmDmYUPq+qHjaMh4iCAAgC209UjJPt2FoT3q774RfsRYNKsZN
is0VCR2yr3PNPh1zVmDSsedKjlWKkvQ1yTT/L/5bami6YZsyfStpo6K7Ym2I3LUT
VPe1r1mpvS4=
=bJwS
-----END PGP SIGNATURE-----

--=-0zul8nVdeMz661fyLdCf--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
