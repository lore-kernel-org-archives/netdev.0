From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Tue, 16 Nov 2010 14:44:13 +0100
Message-ID: <1289915053.5372.183.camel@edumazet-laptop>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
	 <20101110.102129.112602843.davem@davemloft.net>
	 <1289414024.2469.20.camel@edumazet-laptop>
	 <20101110.103807.39173013.davem@davemloft.net>
	 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, drosenberg@vsecurity.com,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49983 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373Ab0KPNoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 08:44:19 -0500
Received: by wyb28 with SMTP id 28so717163wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 05:44:17 -0800 (PST)
In-Reply-To: <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 22:08 +0900, Tetsuo Handa a =C3=A9crit=
 :
> In the wake of commit 57fe93b3 "filter: make sure filters dont read
> uninitialized memory", I came up with this patch. I don't know how to=
 test.
> Please review and do tests.
>=20
> This patch optimizes sk_chk_filter(). Using gcc 4.1.2 on x86_32, the =
size of
> net/core/filter.o changed from 7416 bytes to 5260 bytes
> ("make allnoconfig" + CONFIG_NET=3Dy).
>=20
> By the way, if "struct sock_filter *filter" argument of sk_run_filter=
() does
> not change after it was revalidated at sk_chk_filter(), can't we dete=
ct and
> reject "BPF_S_LD_MEM/BPF_S_LDX_MEM before BPF_S_ST/BPF_S_STX" at
> sk_chk_filter()?

Sure, this was the idea, but seems complex because of branches.

Patches are welcomed ;)

> ----------------------------------------
>  From 2bf36130bd4912590b409b47a6a9a82e2884e035 Mon Sep 17 00:00:00 20=
01
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 16 Nov 2010 21:39:50 +0900
> Subject: [PATCH] filter: Optimize instruction revalidation code.
>=20
> Since repeating small value to small value conversion using switch() =
clause's
> case statement is wasteful, this patch instroduces u16 to u16 mapping=
 table
> and removes most of case statements. As a result, the size of net/cor=
e/filter.o
> is reduced by about 30% on x86.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---

Patch seems fine to me, with the 'const' codes[] Michael Tokarev alread=
y
spotted.

Thanks


