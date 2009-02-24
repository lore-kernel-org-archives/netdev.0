From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss modifications for 2x4 HDLC
Date: Wed, 25 Feb 2009 00:38:42 +0100
Message-ID: <m33ae3h0cd.fsf@intrepid.localdomain>
References: <b0438a630902240447y7afe5510u7465804f94c0e22b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	netdev@vger.kernel.org
To: Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez?=
	<gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37053 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016AbZBXXiq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 18:38:46 -0500
In-Reply-To: <b0438a630902240447y7afe5510u7465804f94c0e22b@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Tue\, 24 Feb
 2009 13\:47\:27 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Miguel =C1ngel =C1lvarez <gotzoncabanes@gmail.com> writes:

> I would appreciate your comments very much, because I think this
> functionallity is quite usefull and I would like to add it to the mai=
n
> kernel stream.

Well, I guess it's a bit like a proof of concept rather than
an applicable patch? :-)

And it's based on "chan" branch. This isn't good, the "chan" isn't yet
ready to go upstream, the interface isn't yet stable. It's really
experimental, based on undocumented behaviour etc. Do you need the
"channelized" feature? If not, perhaps you should stick to HDLC-only
David's net-next?

Ok. The following doesn't IMHO make sense:

> @@ -349,12 +294,58 @@
>  		.set_clock	=3D hss_set_clock,
>  		.open		=3D hss_open,
>  		.close		=3D hss_close,
> -		.txreadyq	=3D 2,
> +		.txreadyq	=3D 32,
> +		.hss        =3D 0,
> +		.hdlc       =3D 0,
>  	}, {
>  		.set_clock	=3D hss_set_clock,
>  		.open		=3D hss_open,
>  		.close		=3D hss_close,
> -		.txreadyq	=3D 19,
> +		.txreadyq	=3D 36,
> +		.hss        =3D 1,
> +		.hdlc       =3D 0,
> +	}, {
> +		.set_clock	=3D hss_set_clock,
> +		.open		=3D hss_open,
> +		.close		=3D hss_close,

There are only two HSS devices on the chip. Not 8 :-)

> @@ -367,6 +358,30 @@
>  		.name			=3D "ixp4xx_hss",
>  		.id			=3D 1,
>  		.dev.platform_data	=3D hss_plat + 1,
> +	}, {
> +		.name			=3D "ixp4xx_hss",
> +		.id			=3D 2,
> +		.dev.platform_data	=3D hss_plat + 2,
> +	}, {
> +		.name			=3D "ixp4xx_hss",
> +		.id			=3D 3,
> +		.dev.platform_data	=3D hss_plat + 3,

Same here.

This only needs a tiny change, increasing the number of HDLC devices
to 2 or 4 (for each HSS), adding the extra queue numbers etc.

This is completely orthogonal to:
a) clocks
b) channelized "services"
c) sync options (excluding 1024-bit max length).

The clock generator is a different thing and needs to be investigated.
Copying Intel's table doesn't make sense here (especially given the
internal clocks are rarely used). Do you need internal clocks?

Channelized thing needs a stable userspace interface first, it really
have to be discussed on netdev.

Sync options are simply independent.

I know I promised you I'll look at this stuff soon. Unfortunately, that
"soon" is a bit less "soon" than I though. Will look when able,
currently I'm really overwhelmed.
--=20
Krzysztof Halasa
