From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 16:10:29 +0200
Message-ID: <1274278229.2766.112.camel@edumazet-laptop>
References: <20100519075721.GA23926@gondor.apana.org.au>
	 <1274256582.2766.5.camel@edumazet-laptop>
	 <1274257089.2766.7.camel@edumazet-laptop>
	 <20100519120547.GB26584@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:23860 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab0ESOKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 10:10:34 -0400
Received: by fg-out-1718.google.com with SMTP id d23so68531fga.1
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 07:10:33 -0700 (PDT)
In-Reply-To: <20100519120547.GB26584@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 08:05 -0400, Neil Horman a =C3=A9crit :
> On Wed, May 19, 2010 at 10:18:09AM +0200, Eric Dumazet wrote:
> > Le mercredi 19 mai 2010 =C3=A0 10:09 +0200, Eric Dumazet a =C3=A9cr=
it :
> >=20
> > > Another concern I have is about RPS.
> > >=20
> > > netif_receive_skb() must be called from process_backlog() context=
, or
> > > there is no guarantee the IPI will be sent if this skb is enqueue=
d for
> > > another cpu.
> >=20
> > Hmm, I just checked again, and this is wrong.
> >=20
> > In case we enqueue skb on a remote cpu backlog, we also
> > do __raise_softirq_irqoff(NET_RX_SOFTIRQ); so the IPI will be done
> > later.
> >=20
> But if this happens, then we loose the connection between the packet =
being
> received and the process doing the reception, so the network cgroup c=
lassifier
> breaks again.
>=20
> Performance gains are still a big advantage here of course.

RPS is enabled on a per device (or more precisely per subqueue) basis, =
and disabled
by default, so if cgroup classifier is needed, it should work as is.

Speaking of net/sched/cls_cgroup.c, I am contemplating following
sequence :

rcu_read_lock();
classid =3D task_cls_state(current)->classid;
rcu_read_unlock();

RCU is definitly so special (should I say magic ?), that we use it even
if not needed. It makes us happy...




