From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 5/5] net: dsa: exit probe if no switch were found
Date: Sat, 3 Oct 2015 13:27:39 -0700
Message-ID: <56103A3B.4020102@gmail.com>
References: <560FE587.80307@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560FE587.80307@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/10/2015 07:26, Neil Armstrong a =C3=A9crit :
> If no switch were found in dsa_setup_dst, return -ENODEV and
> exit the dsa_probe cleanly.
>=20
> Tested-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---

[snip]

>  static int dsa_probe(struct platform_device *pdev)
> @@ -926,9 +937,9 @@ static int dsa_probe(struct platform_device *pdev=
)
>=20
>  	platform_set_drvdata(pdev, dst);
>=20
> -	dsa_setup_dst(dst, dev, &pdev->dev, pd);
> -
> -	return 0;
> +	ret =3D dsa_setup_dst(dst, dev, &pdev->dev, pd);
> +	if (!ret)
> +		return 0;

That logic is a little weird, I would just go with something like this:

ret =3D dsa_setup_dst(ds, dev, &pdev->dev, pd);
if (ret)
	goto out;

return 0;
--=20
=46lorian
