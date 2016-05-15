From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/9] bnxt_en: Add Support for
 ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPRO
Date: Sun, 15 May 2016 02:31:57 +0100
Message-ID: <1463275917.2631.31.camel@decadent.org.uk>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
	 <1463272188-30025-3-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-d4QEXeeU5psmcPQ0Xa8r"
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46372 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753994AbcEOBcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 21:32:10 -0400
In-Reply-To: <1463272188-30025-3-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-d4QEXeeU5psmcPQ0Xa8r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-05-14 at 20:29 -0400, Michael Chan wrote:
> From: Ajit Khaparde <ajit.khaparde@broadcom.com>
[...]
> +	/* Read A2 portion of the EEPROM */
> +	if (length) {
> +		start -=3D ETH_MODULE_SFF_8436_LEN;
> +		bnxt_read_sfp_module_eeprom_info(bp, I2C_DEV_ADDR_A2, 1, start,
> +						=C2=A0length, data + start);

The output address calculation (data + start) makes no sense at all.
If eeprom->offset < ETH_MODULE_SFF_8436_LEN then start =3D=3D 0 here and
this read overwrites earlier data in the output buffer. =C2=A0If
eeeprom->offset > ETH_MODULE_SFF_8436_LEN then start > 0 here and this
overruns the output buffer.

I think that 'data' should be incremented along with 'start' in the
previous if-block.

Ben.

> +	}
> +	return rc;
> +}
[...]

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-d4QEXeeU5psmcPQ0Xa8r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXN9GNAAoJEOe/yOyVhhEJeoEP/A5Mc+EBZgoMmzotW0WQfmIq
rKsJrNPJdlEGVTivm1DpbXC3ZsuDcjYXNAe1MB2YjNZIkpQyxIhPM131yNGpUL5b
66g0irlcJVPtZ8X1SrySgqJaRfdfolJPP/geIiqpU4WGatpBqx4TzdrXibnmOGq7
gKGXBa8bGo9pK/CTIl9PXYkPoLVU3oswtIAbla5vG8FEYJpCo2RtTKP4Mm3mSslT
83WNtGR4yy488gSvJNSw9fGPM6RHc+bXZmAaFTLRCL8KgfQa2g94uslZ64p75Wj2
ReaTMNf/8uxCbMdQ3ECQrt+AwriABtPhCaZev31zp/NycPbWDMLyKGAL8TTzqbNN
/GMkgHhR0/M3B1BrFkiCZ4/mbqFpPZBC0gJHLB6GaGpmmZxi+6XMkd33vR8aCAPv
7sERntXxKFPc6hpLkpRA/hQPwE2JPoL5tISNW54qVYYjddERfrRxDVBlJekwsGm5
st+iBP6LVyHyIzSk5/2x/vvgyLQaBPrLcJ9LQRE/0Sqy7uFEME2op4fdeSv466IZ
NXKljz+kxpAX1hTMPwskqhW0zWdmBpT19BY7vxWldKmFZj9QDnEgGhQ3D5Y1M3s9
4+DRnwMsjMdzaPITawXYee2+USzzRT/A2yZXWWy58WvmeVRaUQOhKDfSiE1gLsr9
08BS0/yjxdTWrSdMdqnT
=Q9Pw
-----END PGP SIGNATURE-----

--=-d4QEXeeU5psmcPQ0Xa8r--
