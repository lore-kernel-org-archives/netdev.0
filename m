From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 10:31:03 -0400
Message-ID: <20100519143103.GB26519@hmsreliant.think-freely.org>
References: <20100519075721.GA23926@gondor.apana.org.au>
 <1274256582.2766.5.camel@edumazet-laptop>
 <1274257089.2766.7.camel@edumazet-laptop>
 <20100519120547.GB26584@hmsreliant.think-freely.org>
 <1274278229.2766.112.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54432 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab0ESObO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 10:31:14 -0400
Content-Disposition: inline
In-Reply-To: <1274278229.2766.112.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 04:10:29PM +0200, Eric Dumazet wrote:
> Le mercredi 19 mai 2010 =E0 08:05 -0400, Neil Horman a =E9crit :
> > On Wed, May 19, 2010 at 10:18:09AM +0200, Eric Dumazet wrote:
> > > Le mercredi 19 mai 2010 =E0 10:09 +0200, Eric Dumazet a =E9crit :
> > >=20
> > > > Another concern I have is about RPS.
> > > >=20
> > > > netif_receive_skb() must be called from process_backlog() conte=
xt, or
> > > > there is no guarantee the IPI will be sent if this skb is enque=
ued for
> > > > another cpu.
> > >=20
> > > Hmm, I just checked again, and this is wrong.
> > >=20
> > > In case we enqueue skb on a remote cpu backlog, we also
> > > do __raise_softirq_irqoff(NET_RX_SOFTIRQ); so the IPI will be don=
e
> > > later.
> > >=20
> > But if this happens, then we loose the connection between the packe=
t being
> > received and the process doing the reception, so the network cgroup=
 classifier
> > breaks again.
> >=20
> > Performance gains are still a big advantage here of course.
>=20
> RPS is enabled on a per device (or more precisely per subqueue) basis=
, and disabled
> by default, so if cgroup classifier is needed, it should work as is.
>=20
> Speaking of net/sched/cls_cgroup.c, I am contemplating following
> sequence :
>=20
> rcu_read_lock();
> classid =3D task_cls_state(current)->classid;
> rcu_read_unlock();
>=20
Yeah, I'd noticed there was no write side to that, but hadn't quite got=
ten to
investigating  that further :)

> RCU is definitly so special (should I say magic ?), that we use it ev=
en
> if not needed. It makes us happy...
>=20
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
