From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 2/2] net: dsa: introduce MICREL
	KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 17:00:25 -0400
Message-ID: <AANLkTikoSb8WA40teXaYvaPf1XsC4r7ySWZOBTKug4ip@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<1279719442-10174-2-git-send-email-vapier@gentoo.org> <20100721151608.GM21121@mail.wantstofly.org>
	<AANLkTinoVsz1YsWc3VSAqPPgH_L19B541A72zkWPxjM8@mail.gmail.com>
	<AANLkTiljQD8CIBtHcMqXdGQILCLDsU-6brjdWB2yB_mN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58855 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757155Ab0GUVAq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 17:00:46 -0400
Received: by wyf19 with SMTP id 19so31142wyf.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 14:00:45 -0700 (PDT)
In-Reply-To: <AANLkTiljQD8CIBtHcMqXdGQILCLDsU-6brjdWB2yB_mN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 16:31, Karl Beldan wrote:
> On Wed, Jul 21, 2010 at 6:05 PM, Mike Frysinger wrote:
>> On Wed, Jul 21, 2010 at 11:16, Lennert Buytenhek wrote:
>>> On Wed, Jul 21, 2010 at 09:37:22AM -0400, Mike Frysinger wrote:
>>>> +static int ksz8893m_setup(struct dsa_switch *ds)
>>>> +{
>>>> + =C2=A0 =C2=A0 int i;
>>>> + =C2=A0 =C2=A0 int ret;
>>>> +
>>>> + =C2=A0 =C2=A0 ret =3D ksz8893m_switch_reset(ds);
>>>> + =C2=A0 =C2=A0 if (ret < 0)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>>>
>>> It's pretty ugly that the mdiobus is passed in via the normal means=
,
>>> but a reference to the SPI bus to use is just stuffed into some glo=
bal
>>> variable.
>>>
>>> Can you not access all registers via MII?
>>
>> it depends on the host mdio bus. =C2=A0if it supports the semi-stand=
ard
>> behavior of toggling the OP field of MDIO frames, then yes, you can =
do
>> it via MII. =C2=A0but i dont think the current mdio framework in the=
 kernel
>> keeps track of that functionality, so there isnt a way in the driver
>> to say "is this possible, else fall back to SPI".
>
> Are you referring to SMI ?

that is the term the ksz datasheet uses (Serial Management Interface),
but i'm not aware of it being a standardized term.  even the ksz
datasheet admits that its behavior is a bit non-standard.  the
Blackfin MAC doesnt support it so we have no way of testing the it as
that is the MAC on the board with the ksz switch.
-mike
