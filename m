From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] fix net/sched compile error
Date: Thu, 14 May 2015 22:56:39 +0300
Message-ID: <5554FDF7.7010406@cogentembedded.com>
References: <5554CE47.8070709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34661 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422667AbbENT4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 15:56:44 -0400
Received: by laat2 with SMTP id t2so84029622laa.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 12:56:42 -0700 (PDT)
In-Reply-To: <5554CE47.8070709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/14/2015 07:33 PM, Brian Haley wrote:

> Fix compile error in net/sched/cls_flower.c

>      net/sched/cls_flower.c: In function =E2=80=98fl_set_key=E2=80=99=
:
>      net/sched/cls_flower.c:240:3: error: implicit declaration of fun=
ction
> =E2=80=98tcf_change_indev=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
>         err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);

> Introduced in 77b9900ef53ae047e36a37d13a2aa33bb2d60641

> Signed-off-by: Brian Haley <brian.haley@hp.com>

> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> index 9bc654c..8c8f34e 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c
> @@ -234,15 +234,15 @@ static void fl_set_key_val(struct nlattr **tb,
>   static int fl_set_key(struct net *net, struct nlattr **tb,
>                 struct fl_flow_key *key, struct fl_flow_key *mask)
>   {
> -    int err;
> -
> +#ifdef CONFIG_NET_CLS_IND
>       if (tb[TCA_FLOWER_INDEV]) {
> -        err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);
> +        int err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);

    Empty line needed here.

>           if (err < 0)
>               return err;
>           key->indev_ifindex =3D err;
>           mask->indev_ifindex =3D 0xffffffff;
>       }
> +#endif
[...]

WBR, Sergei
