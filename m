From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 26/28] dsa: Convert mv88e6xxx into a library allowing driver modules
Date: Thu, 21 Jan 2016 16:29:55 -0500
Message-ID: <87twm639kc.fsf@ketchup.mtl.sfl>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch> <1450875402-20740-27-git-send-email-andrew@lunn.ch> <567DB98B.1070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54761 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbcAUVaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 16:30:03 -0500
In-Reply-To: <567DB98B.1070709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Florian,

=46lorian Fainelli <f.fainelli@gmail.com> writes:

> Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
>> Turn mv88e6xxx into a library module, by exporting its symbols.  Hav=
e
>> each driver register their own driver functions with the DSA core in
>> there init function.
>>=20
>> This results in each driver being a loadable module.
>>=20
>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>> ---
>
> [snip]
>
>> +obj-$(CONFIG_NET_DSA_MV88E6XXX) +=3D mv88e6xxx.o
>> +obj-$(CONFIGNET_DSA_MV88E6131)  +=3D mv88e6123.o
>
> Missing underscore here between CONFIG and NET.
>
>> +obj-$(CONFIG_NET_DSA_MV88E6131) +=3D mv88e6131.o
>> +obj-$(CONFIG_NET_DSA_MV88E6352) +=3D mv88e6352.o
>> +obj-$(CONFIG_NET_DSA_MV88E6171) +=3D mv88e6171.o
>>  obj-$(CONFIG_NET_DSA_BCM_SF2)	+=3D bcm_sf2.o
>> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123=
=2Ec
>> index bb39720f3e8b..9680e59fd2ae 100644
>> --- a/drivers/net/dsa/mv88e6123.c
>> +++ b/drivers/net/dsa/mv88e6123.c
>> @@ -167,7 +167,21 @@ static struct platform_driver mv88e6123_driver =
=3D {
>>  		.of_match_table =3D mv88e6123_of_match,
>>  	},
>>  };
>> -module_platform_driver(mv88e6123_driver);
>> =20
>> +static int __init mv88e6123_init(void)
>> +{
>> +	register_switch_driver(&mv88e6123_switch_driver);
>> +
>> +	return platform_driver_register(&mv88e6123_driver);
>> +}
>> +
>> +static void __exit mv88e6123_exit(void)
>> +{
>> +	platform_driver_unregister(&mv88e6123_driver);
>> +	unregister_switch_driver(&mv88e6123_switch_driver);
>> +}
>
> I think Vivien had started something like this, but it could be nice =
to
> have a helper function/macro which reduces the boilerplate code, not
> critical for now though.

Indeed I did suggest this macro and exporting in the past, without
success though:

    https://lkml.org/lkml/2015/5/2/152

Maybe the other approach with a reference driver (e.g. mv88e6352.c)
declaring a table of supported switch names is more natural?

Most Linux drivers factorize the support for similar devices this way
(e.g. lm75, ...).

Thanks,
-v
