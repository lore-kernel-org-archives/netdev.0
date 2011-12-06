From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 06 Dec 2011 09:51:36 +0100
Message-ID: <1323161496.2448.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <03369d06-ee52-4eef-a8b6-5a21e6d56840@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50512 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932971Ab1LFIvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 03:51:40 -0500
Received: by qadb40 with SMTP id b40so1832790qad.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 00:51:39 -0800 (PST)
In-Reply-To: <03369d06-ee52-4eef-a8b6-5a21e6d56840@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 03:39 -0500, John A. Sullivan III=
 a =C3=A9crit :

> > ifconfig eth2 txqueuelen 0
> > tc qdisc add dev eth2 root pfifo
> > tc qdisc del dev eth2 root
> >=20
> >=20
> >=20
> >=20
> Really? I didn't know one could do that.  Thanks.  However, with no
> queue length, do I have a significant risk of dropping packets? To
> answer your other response's question, these are Intel quad port e100=
0
> cards.  We are frequently pushing them to near line speed so
> 1,000,000,000 / 1534 / 8 =3D 81,486 pps - John

You can remove qdisc layer, since NIC itself has a TX ring queue

(check exact value with ethtool -g ethX)

# ethtool -g eth2
Ring parameters for eth2:
Pre-set maximums:
RX:		4078
RX Mini:	0
RX Jumbo:	0
TX:		4078
Current hardware settings:
RX:		254
RX Mini:	0
RX Jumbo:	0
TX:		4078      ---- HERE ----
