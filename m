From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 01:42:25 +0200
Message-ID: <1271806945.7895.581.camel@edumazet-laptop>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <1271802676.7895.457.camel@edumazet-laptop>
	 <v2n46c8cb3e1004201618s37e9f0c6j7527e59673a34322@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:60162 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab0DTXmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:42:33 -0400
Received: by bwz25 with SMTP id 25so7450679bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:42:32 -0700 (PDT)
In-Reply-To: <v2n46c8cb3e1004201618s37e9f0c6j7527e59673a34322@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 04:18 +0500, Gaspar Chilingarov a =C3=A9=
crit :
> >
> > Its doable, only if you bind() your sockets before connect()
> >
> > For each socket, you'll need to chose an (local IP, local port) not
> > already in use.
> >
> > kernel wont magically select one source IP from the pool you have.
> >
>=20
> I expect that I should select source IP and kernel should find some
> unused local_port for me.
>=20
> I'm binding before the connect, of course ;)
>=20
>=20

Yes, you bind the IP, but let kernel choose the port.

In this case, kernel is a bit dumb (or too smart ?)

If you want to check source, its in file net/ipv4/inet_connection_sock.=
c

function inet_csk_get_port()

you can remove the=20

if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {=20
	spin_unlock(&head->lock);=20
	snum =3D smallest_rover;=20
	goto have_snum;
}

It will solve your problem (but bind() will probably be slow)



