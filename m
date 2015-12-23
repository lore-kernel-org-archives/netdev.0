From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 25/28] Documentation: DSA: Describe how probe of DSA
 and switches work.
Date: Wed, 23 Dec 2015 12:48:28 -0800
Message-ID: <567B089C.7030108@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-26-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34779 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933212AbbLWUsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:48:33 -0500
Received: by mail-oi0-f52.google.com with SMTP id o124so129393668oia.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:48:30 -0800 (PST)
In-Reply-To: <1450875402-20740-26-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> With the introduction of switches as linux devices and the use of the
> component framework, probing has become more complex. Add some
> documentation.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  Documentation/networking/dsa/dsa.txt | 48 ++++++++++++++++++++++++++=
++++++++++
>  1 file changed, 48 insertions(+)
>=20
> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/net=
working/dsa/dsa.txt
> index aa9c1f9313cd..376afa135a81 100644
> --- a/Documentation/networking/dsa/dsa.txt
> +++ b/Documentation/networking/dsa/dsa.txt
> @@ -398,6 +398,54 @@ Switch configuration
>    on the management interface and "hardcode"/"force" this MAC addres=
s for the
>    CPU/management interface as an optimization
> =20
> +Call flow
> +---------
> +
> +With the ability for switch devices to be true linux devices, the ca=
ll
> +flow is somewhat complex. The component framework is used to link th=
e
> +dsa framework as the master, with switch devices, as slaves.
> +
> +A switch device should add itself as a component in its probe
> +function.
> +
> +The DSA framework can either be configured using a platform_data
> +structure or from the device tree. If device tree is being used, the
> +dsa framework probe function will allocate a platform_data structure=
,
> +and populate it using the device tree, via the dsa_of_probe()
> +function.  Within the DSA device tree, switch devices are represente=
d
> +by a phandle to the switch device. These phandles are saved into the
> +platform data so that when switch slaves register themselves, they c=
an
> +be correctly positioned in the DSA cluster.

Humm, I guess I am still not clear on that, in a DT-only system, do I
still need to get the DSA platform device to be probed via DT, along
with references to the switches I want? If that is the case, that seems
a little awkward, could not we probe the individual switches, and see i=
f
they need DSA instead? Or is that how the component framework works,
just being a bit confused here.

Thanks!
--=20
=46lorian
