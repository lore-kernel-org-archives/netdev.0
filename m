From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC] Reset pins of phys and their representation in a device
 tree
Date: Thu, 12 May 2016 15:25:02 +0300
Message-ID: <e75ab3a0-da5e-fef1-d5e1-65c37e7714eb@cogentembedded.com>
References: <20160512071542.GC30822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34622 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbcELMZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 08:25:08 -0400
Received: by mail-lb0-f174.google.com with SMTP id n11so10078597lbh.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 05:25:07 -0700 (PDT)
In-Reply-To: <20160512071542.GC30822@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/12/2016 10:15 AM, Uwe Kleine-K=F6nig wrote:

> I have a machine here where the reset pin of the phy is connected to =
a
> GPIO.
>
> There are different possibilities available today to handle this
> situation, here are the ones I'm aware of:
>
>  - Use a gpio-hog to set the reset gpio to non-active
>    This might result in dependency problems (and that's what I am
>    currently faced with) because there is no connection in the device
>    tree between the hog and the phy.
>
>  - [Documentation/devicetree/bindings/net/fsl-fec.txt]
>    The fec node supports properties
>
> 	phy-reset-gpios =3D <&gpio2 14 0>;
> 	phy-reset-duration =3D <200> /* milliseconds */;
>
>    Something similar exists in TI's vendor kernel
>    (http://git.ti.com/ti-linux-kernel/ti-linux-kernel/commit/17d192b9=
99ee904ced223c16cef76111a51c461b)
>    with different (and IMHO bader) naming.
>    This is the wrong place to specify the gpios; they shouldn't be in=
 the
>    mac's node, but in a phy node instead.
>
> So what I actually want is to put the gpio specification in the right
> place and let it look as follows:
>
> 	mymdiobus {
> 		[...]
> 		myfirstphy: ethernet-phy@0 {
> 			compatible =3D "ethernet-phy-ieee802.3-c22";
> 			reg =3D <0>;
>
> 			reset-gpios =3D <&gpio2 14 0>;
> 			reset-duration-ms =3D <200>;
> 		};
>
> 		mysecondphy: ethernet-phy@2 {
> 			compatible =3D "ethernet-phy-ieee802.3-c22";
> 			reg =3D <2>;
>
> 			reset-gpios =3D <&gpio3 10 0>;
> 			reset-duration-ms =3D <200>;
> 		};
> 	};
>
> And with this we could defer probe of &myfirstphy if &gpio2 isn't
> available yet.
>
> Does this sound sensible? Does something like that already exist whic=
h I
> missed? Any further ideas/comments?

http://patchwork.ozlabs.org/patch/616495/

    I'll post a new version RSN.

> Best regards
> Uwe

MBR, Sergei
