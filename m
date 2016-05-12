From: Javier Martinez Canillas <javier@dowhile0.org>
Subject: Re: [RFC] Reset pins of phys and their representation in a device tree
Date: Thu, 12 May 2016 09:40:01 -0400
Message-ID: <CABxcv==YQshEvUw2a91nqjqrT3JU52Yzy4RbcWiTS-nWMf2m=Q@mail.gmail.com>
References: <20160512071542.GC30822@pengutronix.de>
	<e75ab3a0-da5e-fef1-d5e1-65c37e7714eb@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	=?UTF-8?Q?Krzysztof_Koz=C5=82owski?= <k.kozlowski@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:33216 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbcELNkC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 09:40:02 -0400
Received: by mail-ig0-f196.google.com with SMTP id rc4so6808187igc.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 06:40:01 -0700 (PDT)
In-Reply-To: <e75ab3a0-da5e-fef1-d5e1-65c37e7714eb@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding Krzysztof as cc]

On Thu, May 12, 2016 at 8:25 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 5/12/2016 10:15 AM, Uwe Kleine-K=C3=B6nig wrote:
>
>> I have a machine here where the reset pin of the phy is connected to=
 a
>> GPIO.
>>
>> There are different possibilities available today to handle this
>> situation, here are the ones I'm aware of:
>>
>>  - Use a gpio-hog to set the reset gpio to non-active
>>    This might result in dependency problems (and that's what I am
>>    currently faced with) because there is no connection in the devic=
e
>>    tree between the hog and the phy.
>>
>>  - [Documentation/devicetree/bindings/net/fsl-fec.txt]
>>    The fec node supports properties
>>
>>         phy-reset-gpios =3D <&gpio2 14 0>;
>>         phy-reset-duration =3D <200> /* milliseconds */;
>>
>>    Something similar exists in TI's vendor kernel
>>
>> (http://git.ti.com/ti-linux-kernel/ti-linux-kernel/commit/17d192b999=
ee904ced223c16cef76111a51c461b)
>>    with different (and IMHO bader) naming.
>>    This is the wrong place to specify the gpios; they shouldn't be i=
n the
>>    mac's node, but in a phy node instead.
>>
>> So what I actually want is to put the gpio specification in the righ=
t
>> place and let it look as follows:
>>
>>         mymdiobus {
>>                 [...]
>>                 myfirstphy: ethernet-phy@0 {
>>                         compatible =3D "ethernet-phy-ieee802.3-c22";
>>                         reg =3D <0>;
>>
>>                         reset-gpios =3D <&gpio2 14 0>;
>>                         reset-duration-ms =3D <200>;
>>                 };
>>
>>                 mysecondphy: ethernet-phy@2 {
>>                         compatible =3D "ethernet-phy-ieee802.3-c22";
>>                         reg =3D <2>;
>>
>>                         reset-gpios =3D <&gpio3 10 0>;
>>                         reset-duration-ms =3D <200>;
>>                 };
>>         };
>>
>> And with this we could defer probe of &myfirstphy if &gpio2 isn't
>> available yet.
>>
>> Does this sound sensible? Does something like that already exist whi=
ch I
>> missed? Any further ideas/comments?
>
>
> http://patchwork.ozlabs.org/patch/616495/
>
>    I'll post a new version RSN.
>

This seems to be similar to what's needed by MMC/SD/SDIO devices (i.e:
a WiFi chip) that needs some power sequence for reset and be
enumerable.

Krzysztof has been working  to make the MMC pwrseq framework more
generic [0] since he wants to use it also for built-in USB devices.

=46rom a quick look at the patches mentioned in this thread, it seems
that the same framework can be used to reset the PHYs unless I'm
missing something. Have you considered using this? It would be good if
there is a consistent way to define the power sequence for devices
across the different subsystems.

[0]: https://lkml.org/lkml/2016/5/5/230

Best regards,
Javier
