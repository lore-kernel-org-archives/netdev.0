From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Wed, 04 Jan 2012 01:14:58 +0100
Message-ID: <1325636098.30256.12.camel@edumazet-laptop>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
	 <1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw427XZj17CtAavJCiZDgPqYu4S5v_fZzoYuZ+p5KbyWAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59194 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab2ADAPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 19:15:03 -0500
Received: by wibhm6 with SMTP id hm6so9532450wib.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 16:15:02 -0800 (PST)
In-Reply-To: <CAA93jw427XZj17CtAavJCiZDgPqYu4S5v_fZzoYuZ+p5KbyWAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 janvier 2012 =C3=A0 00:57 +0100, Dave Taht a =C3=A9crit =
:
> On Tue, Jan 3, 2012 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Here is the code I ran on my test server with 200 netperf TCP_STREA=
M
> > flows with pretty good results (each flow gets 0.5 % of bandwidth)
>=20
> Can I encourage you to always simultaneously run a fping and/or a
> netperf -t TCP_RR
>=20

ping is pretty nice ;)

# ping -c 20 192.168.20.112
PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.251 ms
64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.123 ms
64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.124 ms
64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.108 ms
64 bytes from 192.168.20.112: icmp_req=3D5 ttl=3D64 time=3D0.131 ms
64 bytes from 192.168.20.112: icmp_req=3D6 ttl=3D64 time=3D0.126 ms
64 bytes from 192.168.20.112: icmp_req=3D7 ttl=3D64 time=3D0.156 ms
64 bytes from 192.168.20.112: icmp_req=3D8 ttl=3D64 time=3D0.123 ms
64 bytes from 192.168.20.112: icmp_req=3D9 ttl=3D64 time=3D0.111 ms
64 bytes from 192.168.20.112: icmp_req=3D10 ttl=3D64 time=3D0.129 ms
64 bytes from 192.168.20.112: icmp_req=3D11 ttl=3D64 time=3D0.112 ms
64 bytes from 192.168.20.112: icmp_req=3D12 ttl=3D64 time=3D0.138 ms
64 bytes from 192.168.20.112: icmp_req=3D13 ttl=3D64 time=3D0.118 ms
64 bytes from 192.168.20.112: icmp_req=3D14 ttl=3D64 time=3D0.119 ms
64 bytes from 192.168.20.112: icmp_req=3D15 ttl=3D64 time=3D0.121 ms
64 bytes from 192.168.20.112: icmp_req=3D16 ttl=3D64 time=3D0.125 ms
64 bytes from 192.168.20.112: icmp_req=3D17 ttl=3D64 time=3D0.128 ms
64 bytes from 192.168.20.112: icmp_req=3D18 ttl=3D64 time=3D0.108 ms
64 bytes from 192.168.20.112: icmp_req=3D19 ttl=3D64 time=3D0.149 ms
64 bytes from 192.168.20.112: icmp_req=3D20 ttl=3D64 time=3D0.126 ms

--- 192.168.20.112 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 18999ms
rtt min/avg/max/mdev =3D 0.108/0.131/0.251/0.031 ms


> latency under load test when doing stuff like this?
>=20
> The amount of backlogged bytes is rather impressive...

200 tcp flooding flows... thats pretty normal.

If I add to this load a TCP_RR one I get :

# netperf -H 192.168.20.110 -v 0 -l 10 -t TCP_RR
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.20.110 (192.168.20.110) port 0 AF_INET : demo
7606.18=20


If I stop the flood and start the TCP_RR alone :

# netperf -H 192.168.20.110 -v 0 -l 10 -t TCP_RR
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.20.110 (192.168.20.110) port 0 AF_INET : demo
12031.39=20

And a ping on idle link :
#  ping -c 20 192.168.20.112
PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.119 ms
64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.090 ms
64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.085 ms
64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.087 ms
64 bytes from 192.168.20.112: icmp_req=3D5 ttl=3D64 time=3D0.084 ms
64 bytes from 192.168.20.112: icmp_req=3D6 ttl=3D64 time=3D0.084 ms
64 bytes from 192.168.20.112: icmp_req=3D7 ttl=3D64 time=3D0.088 ms
64 bytes from 192.168.20.112: icmp_req=3D8 ttl=3D64 time=3D0.085 ms
64 bytes from 192.168.20.112: icmp_req=3D9 ttl=3D64 time=3D0.083 ms
64 bytes from 192.168.20.112: icmp_req=3D10 ttl=3D64 time=3D0.082 ms
64 bytes from 192.168.20.112: icmp_req=3D11 ttl=3D64 time=3D0.082 ms
64 bytes from 192.168.20.112: icmp_req=3D12 ttl=3D64 time=3D0.085 ms
64 bytes from 192.168.20.112: icmp_req=3D13 ttl=3D64 time=3D0.086 ms
64 bytes from 192.168.20.112: icmp_req=3D14 ttl=3D64 time=3D0.084 ms
64 bytes from 192.168.20.112: icmp_req=3D15 ttl=3D64 time=3D0.089 ms
64 bytes from 192.168.20.112: icmp_req=3D16 ttl=3D64 time=3D0.081 ms
64 bytes from 192.168.20.112: icmp_req=3D17 ttl=3D64 time=3D0.084 ms
64 bytes from 192.168.20.112: icmp_req=3D18 ttl=3D64 time=3D0.086 ms
64 bytes from 192.168.20.112: icmp_req=3D19 ttl=3D64 time=3D0.084 ms
64 bytes from 192.168.20.112: icmp_req=3D20 ttl=3D64 time=3D0.084 ms

--- 192.168.20.112 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 19000ms
rtt min/avg/max/mdev =3D 0.081/0.086/0.119/0.012 ms


I can do a test on full Gigabit speed (removing the HTB) and 1000 flows
and post results
