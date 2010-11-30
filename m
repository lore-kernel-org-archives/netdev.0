From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Tue, 30 Nov 2010 19:14:15 +0100
Message-ID: <1291140855.2904.148.camel@edumazet-laptop>
References: <20101130135549.GA22688@verge.net.au>  <4CF53AB2.60209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64580 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732Ab0K3SOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:14:20 -0500
Received: by wyb28 with SMTP id 28so5968630wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:14:19 -0800 (PST)
In-Reply-To: <4CF53AB2.60209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 09:56 -0800, Rick Jones a =C3=A9crit :

> Short of packet traces, taking snapshots of netstat statistics before=
 and after=20
> each netperf run might be goodness - you can look at things like rati=
o of ACKs=20
> to data segments/bytes and such.  LRO/GRO can have a non-trivial effe=
ct on the=20
> number of ACKs, and ACKs are what matter for fast retransmit.
>=20
> netstat -s > before
> netperf ...
> netstat -s > after
> beforeafter before after > delta
>=20
> where beforeafter comes (for now, the site will have to go away befor=
e long as=20
> the campus on which it is located has been sold)=20
> ftp://ftp.cup.hp.com/dist/networking/tools/  and will subtract before=
 from after.
>=20
> happy benchmarking,

Yes indeed. With fast enough medium (or small MTUS), we can enter in a
backlog processing problem {filling huge receive queues}, as seen on
loopback lately...

netstat -s can show some receive queue overrun in this case.

    TCPBacklogDrop: xxx



