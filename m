From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Fri, 09 Dec 2011 17:31:04 +0100
Message-ID: <1323448264.5661.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
	 <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <6DA1FA31-8983-4338-A1B8-5697A876E2B6@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33148 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab1LIQbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 11:31:08 -0500
Received: by bkbzv3 with SMTP id zv3so3058734bkb.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 08:31:07 -0800 (PST)
In-Reply-To: <6DA1FA31-8983-4338-A1B8-5697A876E2B6@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 17:17 +0100, Esztermann, Ansga=
r a =C3=A9crit :
> On Dec 9, 2011, at 15:43 , Eric Dumazet wrote:
>=20
> > It seems you have a lot of packet reorders.
> >=20
> > Are you using multipath or some channel bonding ?
>=20
> Not that I am aware of (i.e. not on our end). However, the connection
> will probably routed through a firewall. I will have to check if it i=
s
> configured to avoid reordering.
>=20

Is it a linux based firewall ?

I suspect this firewall terminates a tunnel ?

If so, make sure network interrupts are handled by the same cpu.

(because tunneling means calling netif_rx() : This can be the reason fo=
r
Out Of Order packets, if next hardware interrupt is delivered to anothe=
r
cpu)

We really should call netif_receive_skb() for the first tunnel level to
avoid this...
