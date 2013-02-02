From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tcp_process_frto() should not set snd_cwnd to 0
Date: Sat, 02 Feb 2013 07:14:35 -0800
Message-ID: <1359818075.30177.78.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	 <20130124135120.GD16641@order.stressinduktion.org>
	 <1359777110.30177.58.camel@edumazet-glaptop>
	 <20130202142832.GP8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:35672 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757722Ab3BBPOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 10:14:38 -0500
Received: by mail-da0-f54.google.com with SMTP id n2so2099109dad.27
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2013 07:14:37 -0800 (PST)
In-Reply-To: <20130202142832.GP8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

snd_cwnd minimal value is 1, not 0, or tcp_slow_start()
is broken : infinite loop since commit 9dc274151a548
(tcp: fix ABC in tcp_slow_start())

A separate patch will make tcp_slow_start() more robust.

Reported-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8aca4ee..37760df 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3506,7 +3506,7 @@ static bool tcp_process_frto(struct sock *sk, int=
 flag)
 		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter =3D=3D 1)) {
 			/* Prevent sending of new data. */
 			tp->snd_cwnd =3D min(tp->snd_cwnd,
-					   tcp_packets_in_flight(tp));
+					   max(tcp_packets_in_flight(tp), 1U));
 			return true;
 		}
=20
