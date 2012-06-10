From: Fengguang Wu <wfg@linux.intel.com>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
 net/ipv{4,6}/route.c
Date: Sun, 10 Jun 2012 10:08:01 +0800
Message-ID: <20120610020801.GA9293@localhost>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
 <20120610015832.GA9175@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	containers@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25711 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610Ab2FJCIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 22:08:07 -0400
Content-Disposition: inline
In-Reply-To: <20120610015832.GA9175@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 10, 2012 at 09:58:32AM +0800, Fengguang Wu wrote:
> On Sat, Jun 09, 2012 at 04:32:02PM -0700, David Miller wrote:
> >=20
> > Instead of net/ipv4/inetpeer.c
> >=20
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  include/net/inetpeer.h |    9 +++++++
> >  net/ipv4/inetpeer.c    |   64 ++++++++++++------------------------=
------------
> >  net/ipv4/route.c       |   25 +++++++++++++++++++
> >  net/ipv6/route.c       |   34 ++++++++++++++++++++++++-
> >  4 files changed, 83 insertions(+), 49 deletions(-)
>=20
> Dave,
>=20
> It triggers some warnings:
>=20
> WARNING: net/ipv6/ipv6.o(.text+0x1049c): Section mismatch in referenc=
e from the function ip6_route_cleanup() to the variable .init.data:ipv6=
_inetpeer_ops
> WARNING: net/ipv6/ipv6.o(.text+0x1049c): Section mismatch in referenc=
e from the function ip6_route_cleanup() to the variable .init.data:ipv6=
_inetpeer_ops
> WARNING: net/ipv6/built-in.o(.text+0x1049c): Section mismatch in refe=
rence from the function ip6_route_cleanup() to the variable .init.data:=
ipv6_inetpeer_ops
> WARNING: net/ipv6/built-in.o(.text+0x1049c): Section mismatch in refe=
rence from the function ip6_route_cleanup() to the variable .init.data:=
ipv6_inetpeer_ops
> WARNING: net/built-in.o(.text+0x92658): Section mismatch in reference=
 from the function ip6_route_cleanup() to the variable .init.data:ipv6_=
inetpeer_ops
> WARNING: net/built-in.o(.text+0x92658): Section mismatch in reference=
 from the function ip6_route_cleanup() to the variable .init.data:ipv6_=
inetpeer_ops
> WARNING: vmlinux.o(.text+0x710988): Section mismatch in reference fro=
m the function ip6_route_cleanup() to the variable .init.data:ipv6_inet=
peer_ops
> WARNING: vmlinux.o(.text+0x710988): Section mismatch in reference fro=
m the function ip6_route_cleanup() to the variable .init.data:ipv6_inet=
peer_ops

And in another config, an old error still triggers:

net/ipv4/inetpeer.c: In function =E2=80=98family_to_base=E2=80=99:
net/ipv4/inetpeer.c:397:50: error: =E2=80=98struct net=E2=80=99 has no =
member named =E2=80=98ipv6=E2=80=99
net/ipv4/inetpeer.c:398:1: warning: control reaches end of non-void fun=
ction [-Wreturn-type]

I'm building this patch on top of net-next master.

Thanks,
=46engguang
