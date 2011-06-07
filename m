From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Tue, 07 Jun 2011 07:06:57 +0200
Message-ID: <1307423217.2642.59.camel@edumazet-laptop>
References: <20110606064603.GB31505@secunet.com>
	 <20110606064802.GC31505@secunet.com>
	 <1307345899.3098.3.camel@edumazet-laptop>
	 <20110606085247.GE31505@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34887 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab1FGFHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:07:03 -0400
Received: by wwa36 with SMTP id 36so4517658wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 22:07:01 -0700 (PDT)
In-Reply-To: <20110606085247.GE31505@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 10:52 +0200, Steffen Klassert a =C3=A9crit=
 :
> On Mon, Jun 06, 2011 at 09:38:19AM +0200, Eric Dumazet wrote:
> >=20
> > Woh, I am afraid I wont have time in following days to check your
> > assertion.
>=20
> My test setup was the following:
>=20
> I use an IPsec tunnel with tunnel endpoints 192.168.1.1 and 192.168.1=
=2E2
>=20
> Then I do at 192.168.1.2
>=20
> ping -c1 -M do -s 1410 192.168.1.1
>=20
> PING 192.168.1.1 (192.168.1.1) 1410(1438) bytes of data.
> From 192.168.1.2 icmp_seq=3D1 Frag needed and DF set (mtu =3D 1438)
>=20
> --- 192.168.1.1 ping statistics ---
> 0 packets transmitted, 0 received, +1 errors
>=20
> So the packet matches the mtu but it is not send.
> I used a kernel with your patch as head commit.
>=20
> Reverting your patch (going one commit deeper in the history):
>=20
> ping -c1 -M do -s 1410 192.168.1.1
>=20
> PING 192.168.1.1 (192.168.1.1) 1410(1438) bytes of data.
> 1418 bytes from 192.168.1.1: icmp_seq=3D1 ttl=3D64 time=3D3.01 ms
>=20
> --- 192.168.1.1 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 3.014/3.014/3.014/0.000 ms
>=20
> >=20
> > What about original problem then, how should we fix it ?
> >=20
>=20
> Hm, I don't know. I'll try to reproduce it here.
>=20
> > We do have some cases where at least one fragment (the last one) is
> > oversized.
>=20
> trailer_len is used only on IPsec so the poroblem exists only when
> using IPsec, right?
>=20
> >=20
> > I remember I used Nick Bowler scripts at that time, I might find th=
em
> > again...
>=20
> Would be nice if you could provide these scripts and some information=
s
> on how to reproduce the problem.
>=20

Nick mail was :

http://www.spinics.net/lists/netdev/msg141308.html

Unfortunatly I could not find on my machines where I put my own
scripts...

Not a big deal, I suspect we can revert my commit if you say it added a
regression :)

Thanks


