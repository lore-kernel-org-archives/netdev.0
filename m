From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH] ethoc: Write bus addresses to registers
Date: Thu, 10 Jun 2010 21:56:46 +0200
Message-ID: <1276199806.3004.3.camel@satguru.bonn.nu>
References: <20100523.231712.165155558.davem@davemloft.net>
	 <1276181958-31172-1-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-a41vNtdN8xtQBOdWL1Hd"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:47147 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759449Ab0FJT4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 15:56:47 -0400
In-Reply-To: <1276181958-31172-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a41vNtdN8xtQBOdWL1Hd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hmm... found a little problem here... this bit is dependent on another
patch that should be in there before it... I'd appreciate comment on the
approach of the whole thing and then I'll submit the missing bits in the
correct order.  Thanks and sorry for the confusion...
/Jonas

See my comment below...

> @@ -978,6 +989,12 @@ static int ethoc_probe(struct platform_device *pdev)
>  		priv->dma_alloc =3D buffer_size;
>  	}

---> Missing bits are here:  calculate number of transmission buffers...

> =20
> +	priv->vma =3D devm_kzalloc(&pdev->dev, priv->num_tx*sizeof(void*), GFP_=
KERNEL);

---> And here: should be=20
priv->vma =3D devm_kzalloc(&pdev->dev, (priv->num_tx
+priv->num_rx)*sizeof(void*), GFP_KERNEL);

> +	if (!priv->vma) {
> +		ret =3D -ENOMEM;
> +		goto error;
> +	}
> +
>  	/* Allow the platform setup code to pass in a MAC address. */
>  	if (pdev->dev.platform_data) {
>  		struct ethoc_platform_data *pdata =3D


--=-a41vNtdN8xtQBOdWL1Hd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkwRQ3sACgkQ70gcjN2673PmfgCgxAcEF8WOYxd1BGh4DDQpDgw9
TEYAn1i8ad/QdclpzJkOt9Us9YLU+KFX
=S2Fc
-----END PGP SIGNATURE-----

--=-a41vNtdN8xtQBOdWL1Hd--

