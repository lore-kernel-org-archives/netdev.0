From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] tcp : how many times a frame can possibly be
 retransmitted ?
Date: Thu, 25 Aug 2011 01:00:33 +0200
Message-ID: <1314226834.6797.5.camel@edumazet-laptop>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1108250142030.11551@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62870 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab1HXXAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 19:00:38 -0400
Received: by wyg24 with SMTP id 24so1228371wyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 16:00:37 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108250142030.11551@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 01:44 +0300, Ilpo J=C3=A4rvinen a =C3=
=A9crit :
> On Wed, 24 Aug 2011, Eric Dumazet wrote:
>=20
> > On one dev machine running net-next, I just found strange tcp sessi=
ons
> > that retransmit a frame forever (The other peer disappeared)
> >=20
> > # ss -emoi dst 10.2.1.1
> > State      Recv-Q Send-Q      Local Address:Port          Peer Addr=
ess:Port  =20
> > ESTAB      0      816              10.2.1.2:37930             10.2.=
1.1:ssh      timer:(on,630ms,246) ino:60786 sk:ffff8801189aa400
> > 	 mem:(r0,w3776,f320,t0) ts sack ecn cubic wscale:8,6 rto:1680 rtt:=
16.25/7.5 ato:40 ssthresh:7 send 1.4Mbps rcv_rtt:10 rcv_space:16632
> >=20
> >=20
> > You can see the retransmit count : 246=20
> >=20
> > What possibly can be going on ?
> >=20
> > What happened to backoff ?
> >=20
> > # grep . /proc/sys/net/ipv4/tcp_retries*
> > /proc/sys/net/ipv4/tcp_retries1:3
> > /proc/sys/net/ipv4/tcp_retries2:15
> >=20
> >=20
> >=20
> > extract of tcpdump :
> >=20
> > 12:01:02.074244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128024 59389>
> > 12:01:03.754243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128192 59389>
> > 12:01:05.434245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128360 59389>
> > 12:01:07.114243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128528 59389>
> > 12:01:08.794248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128696 59389>
> > 12:01:10.474242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16128864 59389>
> > 12:01:12.154243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129032 59389>
> > 12:01:13.834241 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129200 59389>
> > 12:01:15.514246 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129368 59389>
> > 12:01:17.194244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129536 59389>
> > 12:01:18.874248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129704 59389>
> > 12:01:20.554243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16129872 59389>
> > 12:01:22.234244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130040 59389>
> > 12:01:23.914244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130208 59389>
> > 12:01:25.594247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130376 59389>
> > 12:01:27.274242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130544 59389>
> > 12:01:28.954242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130712 59389>
> > 12:01:30.634248 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16130880 59389>
> > 12:01:32.314245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131048 59389>
> > 12:01:33.994243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131216 59389>
> > 12:01:35.674250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131384 59389>
> > 12:01:37.354244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131552 59389>
> > 12:01:39.034245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131720 59389>
> > 12:01:40.714245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16131888 59389>
> > 12:01:42.394245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132056 59389>
> > 12:01:44.074242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132224 59389>
> > 12:01:45.754249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132392 59389>
> > 12:01:47.434242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132560 59389>
> > 12:01:49.114247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132728 59389>
> > 12:01:50.794250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16132896 59389>
> > 12:01:52.474247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133064 59389>
> > 12:01:54.154242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133232 59389>
> > 12:01:55.834246 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133400 59389>
> > 12:01:57.514243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133568 59389>
> > 12:01:59.194247 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133736 59389>
> > 12:02:00.874250 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16133904 59389>
> > 12:02:02.554242 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134072 59389>
> > 12:02:04.234243 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134240 59389>
> > 12:02:05.914245 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134408 59389>
> > 12:02:07.594244 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134576 59389>
> > 12:02:09.274249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134744 59389>
> > 12:02:10.954241 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16134912 59389>
> > 12:02:12.634249 IP 10.2.1.2.37930 > 10.2.1.1.ssh: P 0:144(144) ack =
1 win 1002 <nop,nop,timestamp 16135080 59389>
> >=20
> > tcp_retransmit_timer() does the exponential backoff, but something
> > resets icsk_rto to a low value ?
> >=20
> > Ah, it seems to be because of commit f1ecd5d9e7366609=20
> > (Revert Backoff [v3]: Revert RTO on ICMP destination unreachable)
> >=20
> > Since arp resolution (or routing, I dont know yet) fails, an
> >  internal/loopback ICMP host/network unreachable message is=20
> > generated and handled in tcp_v4_err() :
> >=20
> > icsk_backoff-- and icsk_rto is reset.
> >=20
> > I am afraid this can generate a storm (cpu time at very least),
> > in case we have many tcp sessions in this state.
>=20
> But RTO (even without any backoffs) should be lower bounded to some n=
ot so=20
> zeroish value?

Apparently not.

The only thing that protect us from a flood is that ip_error() uses
inetpeer cache to ratelimit the icmp_send(ICMP_DEST_UNREACH)

This is why we get retransmit period >=3D 1 sec

vi +432 net/ipv4/tcp_ipv4.c

                icsk->icsk_backoff--;
                inet_csk(sk)->icsk_rto =3D (tp->srtt ? __tcp_set_rto(tp=
) :
                        TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
                tcp_bound_rto(sk);

and __tcp_set_rto() uses : return (tp->srtt >> 3) + tp->rttvar;
