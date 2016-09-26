From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v4 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Mon, 26 Sep 2016 18:14:51 +0900
Message-ID: <CAAedzxoD6DiNDQUpuiV3tQV0zVmAb=J6968aU02Z+3521u0s3Q@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-3-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35517 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935526AbcIZJPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:15:13 -0400
Received: by mail-wm0-f48.google.com with SMTP id l132so140383571wmf.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:15:13 -0700 (PDT)
In-Reply-To: <1474801390-6891-3-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 September 2016 at 20:03, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>
> replace with extra1/2 magic
>
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/ipv6/addrconf.c | 21 ++++++---------------
>  1 file changed, 6 insertions(+), 15 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 11fa1a5564d4..3a835495fb53 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -5467,20 +5467,6 @@ int addrconf_sysctl_forward(struct ctl_table *ctl,=
 int write,
>  }
>
>  static
> -int addrconf_sysctl_hop_limit(struct ctl_table *ctl, int write,
> -                              void __user *buffer, size_t *lenp, loff_t =
*ppos)
> -{
> -       struct ctl_table lctl;
> -       int min_hl =3D 1, max_hl =3D 255;
> -
> -       lctl =3D *ctl;
> -       lctl.extra1 =3D &min_hl;
> -       lctl.extra2 =3D &max_hl;
> -
> -       return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
> -}
> -
> -static
>  int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
>                         void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> @@ -5713,6 +5699,9 @@ int addrconf_sysctl_ignore_routes_with_linkdown(str=
uct ctl_table *ctl,
>         return ret;
>  }
>
> +static int one =3D 1;
> +static int two_five_five =3D 255;

Should these be const as well?

> +
>  static const struct ctl_table addrconf_sysctl[] =3D {
>         {
>                 .procname       =3D "forwarding",
> @@ -5726,7 +5715,9 @@ static const struct ctl_table addrconf_sysctl[] =3D=
 {
>                 .data           =3D &ipv6_devconf.hop_limit,
>                 .maxlen         =3D sizeof(int),
>                 .mode           =3D 0644,
> -               .proc_handler   =3D addrconf_sysctl_hop_limit,
> +               .proc_handler   =3D proc_dointvec_minmax,
> +               .extra1         =3D &one,
> +               .extra2         =3D &two_five_five,
>         },
>         {
>                 .procname       =3D "mtu",
> --
> 2.8.0.rc3.226.g39d4020
>
