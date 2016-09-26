From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v4 1/7] ipv6 addrconf: enable use of proc_dointvec_minmax
 in addrconf_sysctl
Date: Mon, 26 Sep 2016 18:13:16 +0900
Message-ID: <CAAedzxon5Gyp055SfVmpjW96MXjRiHDtTFBv0uarq-nrHfr0gg@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-2-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36682 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936288AbcIZJNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:13:38 -0400
Received: by mail-wm0-f43.google.com with SMTP id w84so139960685wmg.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:13:37 -0700 (PDT)
In-Reply-To: <1474801390-6891-2-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 September 2016 at 20:03, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/ipv6/addrconf.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2f1f5d439788..11fa1a5564d4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -6044,8 +6044,14 @@ static int __addrconf_sysctl_register(struct net *=
net, char *dev_name,
>
>         for (i =3D 0; table[i].data; i++) {
>                 table[i].data +=3D (char *)p - (char *)&ipv6_devconf;
> -               table[i].extra1 =3D idev; /* embedded; no ref */
> -               table[i].extra2 =3D net;
> +               /* If one of these is already set, then it is not safe to
> +                * overwrite either of them: this makes proc_dointvec_min=
max
> +                * usable.
> +                */
> +               if (!table[i].extra1 && !table[i].extra2) {
> +                       table[i].extra1 =3D idev; /* embedded; no ref */
> +                       table[i].extra2 =3D net;
> +               }
>         }
>
>         snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
> --
> 2.8.0.rc3.226.g39d4020
>

Acked-by: Erik Kline <ek@google.com>
