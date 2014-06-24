From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: filter: Use kcalloc/kmalloc_array to allocate arrays
Date: Tue, 24 Jun 2014 08:03:35 -0700
Message-ID: <CAMEtUuxHyMibXLF2xtfsgjuR5J3F5ozHxA-XKXN6zoH86CJ6ug@mail.gmail.com>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
	<1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:45683 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbaFXPDi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:03:38 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so533877wgg.32
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:03:36 -0700 (PDT)
In-Reply-To: <1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 6:33 AM, Tobias Klauser <tklauser@distanz.ch> w=
rote:
> Use kcalloc/kmalloc_array to make it clear we're allocating arrays. N=
o
> integer overflow can actually happen here, since len/flen is guarante=
ed
> to be less than BPF_MAXINSNS (4096). However, this changed makes sure
> we're not going to get one if BPF_MAXINSNS were ever increased.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

typo in the commit log '=E2=80=A6 this changeD=E2=80=A6'
other than that:
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  net/core/filter.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ed8d929..e44c1c4 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -844,7 +844,7 @@ int sk_convert_filter(struct sock_filter *prog, i=
nt len,
>                 return -EINVAL;
>
>         if (new_prog) {
> -               addrs =3D kzalloc(len * sizeof(*addrs), GFP_KERNEL);
> +               addrs =3D kcalloc(len, sizeof(*addrs), GFP_KERNEL);
>                 if (!addrs)
>                         return -ENOMEM;
>         }
> @@ -1101,7 +1101,7 @@ static int check_load_and_stores(struct sock_fi=
lter *filter, int flen)
>
>         BUILD_BUG_ON(BPF_MEMWORDS > 16);
>
> -       masks =3D kmalloc(flen * sizeof(*masks), GFP_KERNEL);
> +       masks =3D kmalloc_array(flen, sizeof(*masks), GFP_KERNEL);
>         if (!masks)
>                 return -ENOMEM;
>
> --
> 1.7.9.5
>
>
