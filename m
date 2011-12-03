From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 09:53:21 +0100
Message-ID: <1322902401.2762.85.camel@edumazet-laptop>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
	 <1322897233.2762.79.camel@edumazet-laptop>
	 <1322898902.2762.81.camel@edumazet-laptop>
	 <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51833 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab1LCIxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 03:53:25 -0500
Received: by bkbzv3 with SMTP id zv3so49307bkb.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 00:53:24 -0800 (PST)
In-Reply-To: <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 d=C3=A9cembre 2011 =C3=A0 10:18 +0200, Denys Fedoryshchenk=
o a =C3=A9crit :
> On Sat, 03 Dec 2011 08:55:02 +0100, Eric Dumazet wrote:
> > Le samedi 03 d=C3=A9cembre 2011 =C3=A0 08:27 +0100, Eric Dumazet a =
=C3=A9crit :
> >
> >> I believe netfilter tcp conntrack considers SYN|FIN as INVALID
> >>
> >
> > Or if you cannot afford conntracking, just do
> >
> > iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
>=20
>  Sure i did,thanks, but i just was curious, why connection with such=20
>  flags are threated as SYN.
>=20

TCP stack first tries to lookup a socket, given the tuple found in
incoming packet.

This is where your machine is hit : we find the listener socket and loc=
k
it.

Then, once socket was found and locked, state machine handle various
possible states.

In your case, you want to bypass the lookup, and eventually bypass the
IP route lookup as well (to keep IP route cache small)

iptables -t raw -I PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DRO=
P
