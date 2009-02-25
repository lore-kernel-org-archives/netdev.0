From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss modifications for 2x4 HDLC
Date: Wed, 25 Feb 2009 09:43:17 +0100
Message-ID: <b0438a630902250043q7092e82cn4cedc4618ca9a447@mail.gmail.com>
References: <b0438a630902240447y7afe5510u7465804f94c0e22b@mail.gmail.com>
	 <m33ae3h0cd.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f167.google.com ([209.85.220.167]:59467 "EHLO
	mail-fx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbZBYInU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 03:43:20 -0500
Received: by fxm11 with SMTP id 11so3549218fxm.13
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 00:43:17 -0800 (PST)
In-Reply-To: <m33ae3h0cd.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2009/2/25 Krzysztof Halasa <khc@pm.waw.pl>:
> Hi,
>
> Miguel =C1ngel =C1lvarez <gotzoncabanes@gmail.com> writes:
>
>> I would appreciate your comments very much, because I think this
>> functionallity is quite usefull and I would like to add it to the ma=
in
>> kernel stream.
>
> Well, I guess it's a bit like a proof of concept rather than
> an applicable patch? :-)
>
Sure. I have made it work, and just want to explain how. And yes... I
would like to transform it into a valuable patch but need some
guidance.

> And it's based on "chan" branch. This isn't good, the "chan" isn't ye=
t
> ready to go upstream, the interface isn't yet stable. It's really
> experimental, based on undocumented behaviour etc. Do you need the
> "channelized" feature? If not, perhaps you should stick to HDLC-only
> David's net-next?
>
I have not changed of test chan at all... But I didn't even know there
was another version. I have just began with the one in linux-2.6.26.

> Ok. The following doesn't IMHO make sense:
>
>> @@ -349,12 +294,58 @@
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .set_clock =A0 =A0 =A0=3D hss_set_clock,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D hss_open,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .close =A0 =A0 =A0 =A0 =A0=3D hss_close,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .txreadyq =A0 =A0 =A0 =3D 2,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .txreadyq =A0 =A0 =A0 =3D 32,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .hss =A0 =A0 =A0 =A0=3D 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .hdlc =A0 =A0 =A0 =3D 0,
>> =A0 =A0 =A0 }, {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .set_clock =A0 =A0 =A0=3D hss_set_clock,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D hss_open,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .close =A0 =A0 =A0 =A0 =A0=3D hss_close,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .txreadyq =A0 =A0 =A0 =3D 19,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .txreadyq =A0 =A0 =A0 =3D 36,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .hss =A0 =A0 =A0 =A0=3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .hdlc =A0 =A0 =A0 =3D 0,
>> + =A0 =A0 }, {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .set_clock =A0 =A0 =A0=3D hss_set_clock,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D hss_open,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .close =A0 =A0 =A0 =A0 =A0=3D hss_close,
>
> There are only two HSS devices on the chip. Not 8 :-)
>
Well... I am not sure about that. For me each hdlc is a different
network device, so I thing they should have their room in the platform
description... But maybe we can just have two hss, and describing in
each one the txreadyq of each hdlc. In any case... isn't this more
flexible as the user can decide which hdlcs to use?

>> @@ -367,6 +358,30 @@
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D "ixp4xx_hss",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =3D 1,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .dev.platform_data =A0 =A0 =A0=3D hss_pl=
at + 1,
>> + =A0 =A0 }, {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=3D "ixp4xx_hss",
>> + =A0 =A0 =A0 =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D 2,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .dev.platform_data =A0 =A0 =A0=3D hss_plat=
 + 2,
>> + =A0 =A0 }, {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=3D "ixp4xx_hss",
>> + =A0 =A0 =A0 =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D 3,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .dev.platform_data =A0 =A0 =A0=3D hss_plat=
 + 3,
>
> Same here.
Same here

>
> This only needs a tiny change, increasing the number of HDLC devices
> to 2 or 4 (for each HSS), adding the extra queue numbers etc.

Yes... The changes are not much (I thought they were, but I have
refined the patch with time).
>
> This is completely orthogonal to:
> a) clocks
> b) channelized "services"
> c) sync options (excluding 1024-bit max length).

I agree, except that lut must also be taken into account.

>
> The clock generator is a different thing and needs to be investigated=
=2E
> Copying Intel's table doesn't make sense here (especially given the
> internal clocks are rarely used). Do you need internal clocks?
>

I would have liked to use internal clocks, but i obtained 7,8MHz for
the supposed 8.192 MHz configuration from Intel, so finally I had to
implement the external clock.

> Channelized thing needs a stable userspace interface first, it really
> have to be discussed on netdev.
>

I agree.

> Sync options are simply independent.
>

I agree.

> I know I promised you I'll look at this stuff soon. Unfortunately, th=
at
> "soon" is a bit less "soon" than I though. Will look when able,
> currently I'm really overwhelmed.

I know... And I am not pretending you to do all the job. I suppose you
and me are not the only ones interested in HSS, so that is why I have
asked for the comments of anyone interested.

=46or me it was critical to make this work. Now it is working so I have
not as much pressure, but I do not want to forget this, and I want to
share my experience with others.

Miguel =C1ngel =C1lvarez
