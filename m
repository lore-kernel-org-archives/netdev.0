From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH] xen: netback: fix error printf format string.
Date: Mon, 1 Jun 2015 09:29:16 +0100
Message-ID: <1433147356.15036.74.camel@citrix.com>
References: <1432916524-20881-1-git-send-email-ian.campbell@citrix.com>
	 <20150531.212618.1162284397803953903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37021 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbFAI3U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 04:29:20 -0400
In-Reply-To: <20150531.212618.1162284397803953903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-31 at 21:26 -0700, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Fri, 29 May 2015 17:22:04 +0100
>=20
> > drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_b=
uild_gops=E2=80=99:
> > drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98=
%lu=E2=80=99 expects argument of type =E2=80=98long unsigned int=E2=80=99=
, but argument 5 has type =E2=80=98int=E2=80=99 [-Wformat=3D]
> >         (txreq.offset&~PAGE_MASK) + txreq.size);
> >         ^
> >=20
> > txreq.offset and .size are uint16_t fields.
> >=20
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>=20
> This may get rid of the compiler warning on your machine, but it crea=
tes
> one on mine:
>=20
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_bui=
ld_gops=E2=80=99:
> drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98%u=
=E2=80=99 expects argument of type =E2=80=98unsigned int=E2=80=99, but =
argument 5 has type =E2=80=98long unsigned int=E2=80=99 [-Wformat=3D]
>         (txreq.offset&~PAGE_MASK) + txreq.size);
>         ^
>=20
> There is a type involved in this calculation which is arch
> dependent, so you'll need to add a cast or something to
> make this warning go away in all cases.

Ah, I only considered the types txreq.{offset,size} and missed thinking
about PAGE_MASK.

I'll resend with a cast.

Ian.
