From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 21:37:27 +0100
Message-ID: <20091130213727.2f4047d2@houba>
References: <20091127223545.2a752429@houba>
	<alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
	<20091128010156.1219012a@houba>
	<alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
	<20091130195004.38dbc319@houba>
	<alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:49393 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbZK3Uho convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:37:44 -0500
In-Reply-To: <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 30 Nov 2009 22:18:22 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Mon, 30 Nov 2009, Frederic Leroy wrote:
>=20
> Thanks, at least ....3.... shows that cwnd (congestion window, the
> 2nd to last field in /proc/net/tcp) goes to zero which it never ever
> should. ...I'll start reading some code to figure out the cause for
> that.
>=20
> How much is your RTT btw?

The RTT is ~ 1.4ms.
The following trace has a rtt as big as 5ms but most of the time, it's
under 1.4ms and periodically grow to 3ms.=20

-------------------------------------------
64 bytes from sg (192.168.1.19): icmp_seq=3D681 ttl=3D64 time=3D1.26 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D682 ttl=3D64 time=3D1.26 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D683 ttl=3D64 time=3D1.34 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D684 ttl=3D64 time=3D2.01 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D686 ttl=3D64 time=3D2.15 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D687 ttl=3D64 time=3D5.07 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D688 ttl=3D64 time=3D1.19 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D689 ttl=3D64 time=3D1.30 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D690 ttl=3D64 time=3D1.19 ms
64 bytes from sg (192.168.1.19): icmp_seq=3D691 ttl=3D64 time=3D1.14 ms
-------------------------------------------

> The RTO timeout easily goes up to 120
> secods similar to what I found myself already. Thus I'm not sure if
> this stall would be "infinite" after all.

I notice that grep '":0016" /proc/net/tcp' stop to report something whe=
n
it stalls. Is the connection closed ?
=20
> I've some problem in .3. case in  matching timing of the proc/net/tcp
> dump and the tcpdump ... did you perhaps cut it somewhere?

No, I didn't cut it.

> This might
> point out to yet another problem, however, I'm not sure what I can
> atm trust in the logs. ...Timestamps would probably help me a bit
> (I've changed also sleep to do 0.01 granularity):
>=20
> while [ : ]; do date "+%s.%N"; grep ":0016" /proc/net/tcp; sleep
> 0.01; done | tee scp_stall-houba.x.proc_net_tcp
=20
> (Please run start while loop before starting the transfer and all the
> way until the connection is already killed and only then stop the
> loop).

I took care to timings this time. I did as you said.

> What happened in .2. case I've very little idea, proc/net/tcp does
> claim retransmission would have happened on TCP layer but that never
> went into tcpdump log (the kind of thing might have happened in
> the .3. case too which is why I asked for the timestamps for matching
> captures more exactly but there were some retransmissions earlier in
> the log so I cannot be sure). Can you also check that tcpdump doesn't
> lose any packets, it should show: "0 packets dropped by kernel" when
> you ctrl-c it.

I still have the logs, O packet dropped :=20

-------------------------------------------
houba tmp # tcpdump -i wlan1 -s 1500 -w /tmp/ssh_stall-houba.1.pcap -vv
ether host 00:40:45:09:3f:3f tcpdump: listening on wlan1, link-type
EN10MB (Ethernet), capture size 1500 bytes ^C8923 packets captured
8923 packets received by filter
0 packets dropped by kernel
houba tmp # tcpdump -i wlan1 -s 1500 -w /tmp/scp_stall-houba.3.pcap
-vv ether host 00:40:45:09:3f:3f tcpdump: listening on wlan1, link-type
EN10MB (Ethernet), capture size 1500 bytes ^C17045 packets captured
17045 packets received by filter
0 packets dropped by kernel
houba tmp #=20
-------------------------------------------


--=20
=46r=C3=A9d=C3=A9ric Leroy
