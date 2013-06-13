From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [iproute2 PATCH] tc: handle is not used without containing ':'
Date: Thu, 13 Jun 2013 21:39:21 +0400
Message-ID: <51BA03C9.80505@cogentembedded.com>
References: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Philipp_Sch=F6nberger?=
	<ph.schoenberger@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:38724 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757396Ab3FMRja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 13:39:30 -0400
Received: by mail-la0-f54.google.com with SMTP id ec20so9067788lab.41
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 10:39:29 -0700 (PDT)
In-Reply-To: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/13/2013 09:20 PM, Philipp Sch=F6nberger wrote:

> Handle is not used if it is not containing a ':' . This is
> reproducible with these commands.

> /sbin/tc qdisc add dev lo parent 0xffffffff handle 0x10000 pfifo limi=
t 10

> /sbin/tc qdisc show dev lo
> qdisc pfifo 8001: root refcnt 2 limit 10p

> Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com>
> --- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +01=
00
> +++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
> @@ -50,9 +50,14 @@
>       maj =3D strtoul(str, &p, 16);
>       if (p =3D=3D str)
>           return -1;
> -    maj <<=3D 16;
> -    if (*p !=3D ':' && *p!=3D0)
> -        return -1;
> +    if (*p !=3D ':')
> +    {
> +        if(*p!=3D0)

    Maybe you should be more consistent in using space after *if*? :-)

> +            return -1;
> +        else if (TC_H_MIN(maj) !=3D 0)
> +            return -1;
> +    }else

    Space after } seems a good idea too...

> +        maj <<=3D 16;
>   ok:
>       *h =3D maj;
>       return 0;

WBR, Sergei
