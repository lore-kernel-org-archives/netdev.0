From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: some questions of tcp congestion window
Date: Thu, 08 Aug 2013 06:13:09 -0700
Message-ID: <1375967589.4004.89.camel@edumazet-glaptop>
References: <5203F0DD.1090007@gmail.com> <5203F2D1.3030104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dong Fang <yp.fangdong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:40565 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964930Ab3HHNNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:13:11 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so3175779pbc.11
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 06:13:10 -0700 (PDT)
In-Reply-To: <5203F2D1.3030104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 15:34 -0400, Dong Fang wrote:
> On 08/08/2013 03:26 PM, Dong Fang wrote:
> > hi, all
> >
> > I'am reading the tcp/ip network source code(kernel 3.10), i was
> > fogged by the congestion window. so, i want to confirm something
> > about it:
> >
> > Note: sack is disable. and A is sender, B is receiver.
> >
> > 1. at time t, the number of packets in flight is 100. like this=EF=BC=
=9A
> >     u, u+1, u+2, ..., u+99
> >     and suppose u is lost and all other packets are not. so bwtween
> >     t:t+RTT we would have retransmitted u and received 99 dupack.
> >     all of this dupack's ack =3D=3D u, right?
> >
> >     when A recieved 3 dupack, it changed to TCP_CA_Recovery state.
> >     in this state, the congestion window won't grow any more.
> >     then, A retransmit U packet. after that, if A receive a new ack=
,
> >     acked all the packets in flight, so the sock state is changed
> >     to TCP_CA_Open. right?
> >
> > 2. at time t, the number of packets in flight is 100, like this:
> >     u, u+1, u+2, ..., u+99
> >     and suppose u and u+5 is lost and all other packets are not.
> >     between t:t+RTT, we should have retransmitted u and received 99
> >     dupack, all of this dupack's ack =3D=3D u, right?
> >
> >     when A recieved 3 dupack, it changed to Recovery state, then
> >     retransmit U packet, after that, if A receive a new ack,
> >     this ack is only acked for u+5, at this time, current sshresh =3D
> >     cwnd/2 + 5(the first 5 packets was acked), but cwnd > sshresh.
> >     so A won't send any packets to B, and B won't send any ack to
> >     A too, because B have beed send 99 dupack and 1 new ack, it
> >     have done its work, right? the only way to let B send ack to
> >     A is, the retransmit timeout of u+5 packet.
> >
> >     when A was retransmit u+5 packet to B, then B send packet ack
> >     for u+100 to A, this time, the A's cwnd =3D=3D sshresh << 1, en=
ter
> >     CA progress, right?
> can anybody help me? :)

I suggest you download packetdrill and build a test ;)
