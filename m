From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Sun, 16 Jan 2011 10:21:10 +0100
Message-ID: <1295169670.3977.36.camel@edumazet-laptop>
References: <54347.1295168081@internode.on.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: arthur.marsh@internode.on.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64062 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab1APJVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 04:21:19 -0500
Received: by wwa36 with SMTP id 36so4468023wwa.1
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 01:21:18 -0800 (PST)
In-Reply-To: <54347.1295168081@internode.on.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 janvier 2011 =C3=A0 19:24 +1030, Arthur Marsh a =C3=A9cr=
it :

CC people involved with the commit

>=20
> =20
>  This bug was originally posted at https://bugzilla.kernel.org/show_b=
ug.cgi?id=3D26632=20
>=20
> With kernels up to and including 2.6.37-git7, inbound telnetd-ssl con=
nections worked fine.=20
> With kernel 2.6.37-git9 and later inbound telnetd-ssl connections fai=
led, and on machine shut-down, there were warning messages about daemon=
s not return status.=20
> =20
> A git bisect on Linus' kernel tree revealed:=20
> =20
> 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf is the first bad commit=20
> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf=20
> Author: Jan Engelhardt <jengelh@medozas.de>=20
> Date:   Fri Jan 7 03:15:05 2011 +0000=20
> =20
>     netlink: test for all flags of the NLM_F_DUMP composite=20
> =20
>     Due to NLM_F_DUMP is composed of two bits, NLM_F_ROOT | NLM_F_MAT=
CH,=20
>     when doing "if (x & NLM_F_DUMP)", it tests for _either_ of the bi=
ts=20
>     being set. Because NLM_F_MATCH's value overlaps with NLM_F_EXCL,=20
>     non-dump requests with NLM_F_EXCL set are mistaken as dump reques=
ts.=20
> =20
>     Substitute the condition to test for _all_ bits being set.=20
> =20
>     Signed-off-by: Jan Engelhardt <jengelh@medozas.de>=20
>     Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>=20
>     Signed-off-by: David S. Miller <davem@davemloft.net>=20
> =20
> :040000 040000 1a0717ab0c87787309c3c3af88d666b44f327f64=20
> cba6279de85b7ebeaf21f19f1d93b59468fdd01d M      net=20
> =20
> I tried git cherry-pick 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf and =
verified=20
> that the resulting kernel had these problems, then git revert=20
> 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf and verified that the result=
ing kernel=20
> did *not* have problems.=20
> =20
> Arthur.=20


