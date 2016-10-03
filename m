From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Mon, 3 Oct 2016 12:49:45 -0700
Message-ID: <CAM_iQpUaXf6crCbbe3+MKsuchJGBE5hnQEDibgFe-MtBoe2v7A@mail.gmail.com>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34814 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcJCTuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 15:50:06 -0400
Received: by mail-io0-f173.google.com with SMTP id r30so6943424ioi.1
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 12:50:06 -0700 (PDT)
In-Reply-To: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 2, 2016 at 11:41 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> +static const int minus_one =3D -1;
>  static const int one =3D 1;
>  static const int two_five_five =3D 255;
>
> @@ -5789,7 +5790,8 @@ static const struct ctl_table addrconf_sysctl[] =3D=
 {
>                 .data           =3D &ipv6_devconf.rtr_solicits,
>                 .maxlen         =3D sizeof(int),
>                 .mode           =3D 0644,
> -               .proc_handler   =3D proc_dointvec,
> +               .proc_handler   =3D proc_dointvec_minmax,
> +               .extra1         =3D (void *)&minus_one,

The cast is not necessary.
