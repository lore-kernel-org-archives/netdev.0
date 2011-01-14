From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 04:34:27 +0100
Message-ID: <1294976067.3403.118.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop>  <20110113153436.70d3c0a3@s6510>
	 <1294975793.3403.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43171 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab1ANDed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 22:34:33 -0500
Received: by wyb28 with SMTP id 28so2436991wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 19:34:31 -0800 (PST)
In-Reply-To: <1294975793.3403.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 04:29 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le jeudi 13 janvier 2011 =C3=A0 15:34 -0800, Stephen Hemminger a =C3=A9=
crit :
> > CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
> > packet scheduler based on the Random Exponential Drop (RED) algorit=
hm.
> >=20
> > The core idea is:
> >   For every packet arrival:
> >   	Calculate Qave
> > 	if (Qave < minth)=20
> > 	     Queue the new packet
> > 	else=20
> > 	     Select randomly a packet from the queue=20
> > 	     if (both packets from same flow)
> > 	     then Drop both the packets
> > 	     else if (Qave > maxth)
> > 	          Drop packet
> > 	     else
> > 	       	  Admit packet with probability P (same as RED)
> >=20
> > See also:
> >   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a state=
less active
> >    queue management scheme for approximating fair bandwidth allocat=
ion",=20
> >   Proceeding of INFOCOM'2000, March 2000.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> > 0.8 change queue length and holes account.
> >     keep sch->q.qlen updated, and holes counter not needed.
> >=20
> > ---
> >  net/sched/Kconfig     |   11 +
> >  net/sched/Makefile    |    1=20
> >  net/sched/sch_choke.c |  536 +++++++++++++++++++++++++++++++++++++=
+++++++++++++
> >  3 files changed, 548 insertions(+)
> >=20
>=20
> Hi Stephen
>=20
> Your diffstat was an old one, here the right one.
>=20
>  include/linux/pkt_sched.h |   29 +
>  net/sched/Kconfig         |   11=20
>  net/sched/Makefile        |    1=20
>  net/sched/sch_choke.c     |  552 +++++++++++++++++++++++++++++++++++=
+
>=20
>=20
> I tested v8 and found several serious problems, please find a diff of=
 my
> latest changes :
>=20
> - wrong oskb/skb used in choke_enqueue()
> - choke_zap_head_holes() is called from choke_dequeue() and crash if =
we
> dequeued last packet. (!!!)
> - out of bound access in choke_zap_tail_holes()
> - choke_dequeue() can be shorter
> - choke_change() must dequeue/drop in excess packets or risk new arra=
y
> overfill (if we reduce queue limit by tc qdisc change ...)
> - inline is not needed, space errors in include file
>=20
> Thanks !

Hmm, please wait a bit, I had another crash when I stopped my
bench/stress



