From: Dong Fang <yp.fangdong@gmail.com>
Subject: some questions of tcp congestion window
Date: Thu, 08 Aug 2013 15:26:21 -0400
Message-ID: <5203F0DD.1090007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:64281 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757655Ab3HHH0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 03:26:49 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so2834708pbc.29
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 00:26:49 -0700 (PDT)
Received: from [192.168.1.108] ([111.194.92.93])
        by mx.google.com with ESMTPSA id qp10sm14821266pab.13.2013.08.08.00.26.43
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 Aug 2013 00:26:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi, all

I'am reading the tcp/ip network source code(kernel 3.10), i was
fogged by the congestion window. so, i want to confirm something
about it:

Note: sack is disable. and A is sender, B is receiver.

1. at time t, the number of packets in flight is 100. like this=EF=BC=9A
    u, u+1, u+2, ..., u+99
    and suppose u is lost and all other packets are not. so bwtween
    t:t+RTT we would have retransmitted u and received 99 dupack.
    all of this dupack's ack =3D=3D u, right?

    when A recieved 3 dupack, it changed to TCP_CA_Recovery state.
    in this state, the congestion window won't grow any more.
    then, A retransmit U packet. after that, if A receive a new ack,
    acked all the packets in flight, so the sock state is changed
    to TCP_CA_Open. right?

2. at time t, the number of packets in flight is 100, like this:
    u, u+1, u+2, ..., u+99
    and suppose u and u+5 is lost and all other packets are not.
    between t:t+RTT, we should have retransmitted u and received 99
    dupack, all of this dupack's ack =3D=3D u, right?

    when A recieved 3 dupack, it changed to Recovery state, then
    retransmit U packet, after that, if A receive a new ack,
    this ack is only acked for u+5, at this time, current sshresh =3D
    cwnd/2 + 5(the first 5 packets was acked), but cwnd > sshresh.
    so A won't send any packets to B, and B won't send any ack to
    A too, because B have beed send 99 dupack and 1 new ack, it
    have done its work, right? the only way to let B send ack to
    A is, the retransmit timeout of u+5 packet.

    when A was retransmit u+5 packet to B, then B send packet ack
    for u+100 to A, this time, the A's cwnd =3D=3D sshresh << 1, enter
    CA progress, right?
