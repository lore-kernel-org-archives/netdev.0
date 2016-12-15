From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Fix compile warning in get_addr_1
Date: Wed, 14 Dec 2016 19:30:01 -0800
Message-ID: <20161214193001.4857e756@xeon-e3>
References: <1481672072-14140-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33339 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753628AbcLODaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 22:30:25 -0500
Received: by mail-pg0-f49.google.com with SMTP id 3so15019269pgd.0
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 19:30:10 -0800 (PST)
In-Reply-To: <1481672072-14140-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Dec 2016 15:34:32 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> A recent cleanup causes a compile warning on Debian jessie:
>=20
>     CC       utils.o
> utils.c: In function =E2=80=98get_addr_1=E2=80=99:
> utils.c:486:21: warning: passing argument 1 of =E2=80=98ll_addr_a2n=E2=80=
=99 from incompatible pointer type
>    len =3D ll_addr_a2n(&addr->data, sizeof(addr->data), name);
>                      ^
> In file included from utils.c:34:0:
> ../include/rt_names.h:27:5: note: expected =E2=80=98char *=E2=80=99 but a=
rgument is of type =E2=80=98__u32 (*)[8]=E2=80=99
>  int ll_addr_a2n(char *lladdr, int len, const char *arg);
>      ^
>=20
> Revert the removal of the typecast
>=20
> Fixes: e1933b928125 ("utils: cleanup style")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  lib/utils.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/lib/utils.c b/lib/utils.c
> index 316b048abcfc..83c9d097c608 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -483,7 +483,8 @@ int get_addr_1(inet_prefix *addr, const char *name, i=
nt family)
>  	if (family =3D=3D AF_PACKET) {
>  		int len;
> =20
> -		len =3D ll_addr_a2n(&addr->data, sizeof(addr->data), name);
> +		len =3D ll_addr_a2n((char *) &addr->data, sizeof(addr->data),
> +				  name);
>  		if (len < 0)
>  			return -1;
> =20

Thanks was accidental.
