From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 5/5] net: dsa: exit probe if no switch were found
Date: Tue, 6 Oct 2015 08:20:32 +0100
Message-ID: <56137640.8060108@baylibre.com>
References: <560FE587.80307@baylibre.com> <56103A3B.4020102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:32953 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbJFHUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:20:34 -0400
Received: by wiclk2 with SMTP id lk2so152859033wic.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:20:33 -0700 (PDT)
In-Reply-To: <56103A3B.4020102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2015 09:27 PM, Florian Fainelli wrote:
> Le 03/10/2015 07:26, Neil Armstrong a =C3=A9crit :
>> If no switch were found in dsa_setup_dst, return -ENODEV and
>> exit the dsa_probe cleanly.
>>
>> Tested-by: Andrew Lunn <andrew@lunn.ch>
>> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>=20
> [snip]
>=20
>>  static int dsa_probe(struct platform_device *pdev)
>> @@ -926,9 +937,9 @@ static int dsa_probe(struct platform_device *pde=
v)
>>
>>  	platform_set_drvdata(pdev, dst);
>>
>> -	dsa_setup_dst(dst, dev, &pdev->dev, pd);
>> -
>> -	return 0;
>> +	ret =3D dsa_setup_dst(dst, dev, &pdev->dev, pd);
>> +	if (!ret)
>> +		return 0;
>=20
> That logic is a little weird, I would just go with something like thi=
s:
>=20
> ret =3D dsa_setup_dst(ds, dev, &pdev->dev, pd);
> if (ret)
> 	goto out;
>=20
> return 0;
>=20
Yes you are right, the goto out is needed to clean up the of_probe reso=
urces.

I will send a v3 with this fixed.

Neil
