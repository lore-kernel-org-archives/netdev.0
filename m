From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH] tc: handle is not used without containing ':'
Date: Tue, 18 Jun 2013 10:48:05 -0700
Message-ID: <20130618104805.112f186e@nehalam.linuxnetplumber.net>
References: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Philipp =?ISO-8859-1?B?U2No9m5iZXJnZXI=?=
	<ph.schoenberger@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38070 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932458Ab3FRRvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 13:51:12 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so4237004pad.9
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 10:51:11 -0700 (PDT)
In-Reply-To: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Jun 2013 19:20:52 +0200
Philipp Sch=F6nberger  <ph.schoenberger@googlemail.com> wrote:

> Handle is not used if it is not containing a ':' . This is
> reproducible with these commands.
>=20
> /sbin/tc qdisc add dev lo parent 0xffffffff handle 0x10000 pfifo limi=
t 10
>=20
> /sbin/tc qdisc show dev lo
> qdisc pfifo 8001: root refcnt 2 limit 10p
>=20
> Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com>
> --- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +01=
00
> +++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
> @@ -50,9 +50,14 @@
>      maj =3D strtoul(str, &p, 16);
>      if (p =3D=3D str)
>          return -1;
> -    maj <<=3D 16;
> -    if (*p !=3D ':' && *p!=3D0)
> -        return -1;
> +    if (*p !=3D ':')
> +    {
> +        if(*p!=3D0)
> +            return -1;
> +        else if (TC_H_MIN(maj) !=3D 0)
> +            return -1;
> +    }else
> +        maj <<=3D 16;
>  ok:
>      *h =3D maj;
>      return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The syntax for tc has always reqired : after the handle.
 http://www.lartc.org/howto/lartc.qdisc.classful.html

One could argue the error checking could be better, but not worth chang=
ing
the syntax now.
