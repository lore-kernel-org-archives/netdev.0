From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Sat, 18 Oct 2014 08:30:07 -0700
Message-ID: <1413646207.27176.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141017.234817.1456444039400155118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:38501 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaJRPaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 11:30:09 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so2388985pdj.23
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 08:30:09 -0700 (PDT)
In-Reply-To: <20141017.234817.1456444039400155118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 23:48 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 17 Oct 2014 09:17:20 -0700
>=20
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache=
 line
> > misses") added a regression for SO_BINDTODEVICE on IPv6.
> >=20
> > This is because we still use inet6_iif() which expects that IP6 con=
trol
> > block is still at the beginning of skb->cb[]
> >=20
> > This patch adds tcp_v6_iif() helper and uses it where necessary.
> >=20
> > Because __inet6_lookup_skb() is used by TCP and DCCP, we add an iif
> > parameter to it.
> >=20
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache=
 line misses")
>=20
> Applied.

Oh well, I forgot IPV6 could be not present in .config

Will send a patch, sorry for this.

$ make M=3Dnet/ipv4
  CC      net/ipv4/route.o
In file included from net/ipv4/route.c:102:0:
include/net/tcp.h: In function =E2=80=98tcp_v6_iif=E2=80=99:
include/net/tcp.h:738:32: error: =E2=80=98union <anonymous>=E2=80=99 ha=
s no member named =E2=80=98h6=E2=80=99
  return TCP_SKB_CB(skb)->header.h6.iif;
