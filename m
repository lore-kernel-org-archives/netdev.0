From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 12:57:13 -0700
Message-ID: <20081031125713.6c6923de@extreme>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
	<20081031.005219.141937694.davem@davemloft.net>
	<Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
	<20081031.025159.51432990.davem@davemloft.net>
	<490AE1CD.9040207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37384 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbYJaT5R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 15:57:17 -0400
In-Reply-To: <490AE1CD.9040207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2008 11:45:33 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> David Miller a =C3=A9crit :
> > From: "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
> >=20
> >> Let me remind that it is just a single process, so no ping-pong & =
other=20
> >> lock related cache effects should play any significant role here, =
no? (I'm=20
> >> no expert though :-)).
> >=20
> > Not locks or ping-pongs perhaps, I guess.  So it just sends and
> > receives over a socket, implementing both ends of the communication
> > in the same process?
> >=20
> > If hash chain conflicts do happen for those 2 sockets, just travers=
ing
> > the chain 2 entries deep could show up.
>=20
> tbench is very sensible to cache line ping-pongs (on SMP machines of =
course)
>=20
> Just to prove my point, I coded the following patch and tried it
> on a HP BL460c G1. This machine has 2 quad cores cpu=20
> (Intel(R) Xeon(R) CPU E5450  @3.00GHz)
>=20
> tbench 8 went from 2240 MB/s to 2310 MB/s after this patch applied
>=20
> [PATCH] net: Introduce netif_set_last_rx() helper
>=20
> On SMP machine, loopback device (and possibly others net device)
> should try to avoid dirty the memory cache line containing "last_rx"
> field. Got 3% increase on tbench on a 8 cpus machine.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  drivers/net/loopback.c    |    2 +-
>  include/linux/netdevice.h |   16 ++++++++++++++++
>  2 files changed, 17 insertions(+), 1 deletion(-)
>=20
>=20

Why bother with last_rx at all on loopback.  I have been thinking
we should figure out a way to get rid of last_rx all together. It only
seems to be used by bonding, and the bonding driver could do the calcul=
ation
in its receive handling.
