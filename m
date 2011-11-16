From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Subject: Re: [RFC] iproute:  Support cross-compiling.
Date: Wed, 16 Nov 2011 10:53:11 +0000
Message-ID: <4EC39617.5010108@draigBrady.com>
References: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab1KPKxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 05:53:15 -0500
In-Reply-To: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2011 01:04 AM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> This lets users use their own compiler instead of
> hard-coding to use gcc.
>=20
> Also adds tests to disable some things that were not supported
> in my ARM cross-compile toolchain.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 c6e4943... 3b00076... M	Makefile
> :100755 100755 f5c3d40... 680fdcb... M	configure
> :100644 100644 8d03993... 5c91e18... M	ip/Makefile
> :100644 100644 e41a598... 773f7cb... M	ip/ipnetns.c
> :100644 100644 8c25381... d04358d... M	misc/Makefile
>  Makefile      |    2 +-
>  configure     |   88 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++---
>  ip/Makefile   |    8 +++++
>  ip/ipnetns.c  |   17 +++++++++++
>  misc/Makefile |    5 +++
>  5 files changed, 114 insertions(+), 6 deletions(-)
>=20
> diff --git a/Makefile b/Makefile
> index c6e4943..3b00076 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -27,7 +27,7 @@ ADDLIB+=3Ddnet_ntop.o dnet_pton.o
>  #options for ipx
>  ADDLIB+=3Dipx_ntop.o ipx_pton.o
> =20
> -CC =3D gcc
> +CC ?=3D gcc

Right that allows one to override at build time,
supporting clang, ccache, ...

>  HOSTCC =3D gcc
>  CCOPTS =3D -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
>  CFLAGS =3D $(CCOPTS) -I../include $(DEFINES)
> diff --git a/configure b/configure
> index f5c3d40..680fdcb 100755
> --- a/configure
> +++ b/configure
> @@ -3,6 +3,11 @@
>  #
>  INCLUDE=3D${1:-"$PWD/include"}
> =20
> +if [ "_$CC" =3D=3D "_" ]
> +then
> +    CC=3Dgcc
> +fi

Ditto at configure time.
Note the shell idiom for this is
: ${var:=3D"value"}
Note the leading : is required for portability.
Not applicable here, but if you want to set only if unset
(rather than the above which also handles empty), do:
: ${var=3D"value"}

cheers,
P=E1draig.
