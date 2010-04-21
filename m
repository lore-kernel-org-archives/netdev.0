From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 02:14:10 +0200
Message-ID: <1271808850.7895.631.camel@edumazet-laptop>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <n2g46c8cb3e1004201657t50599d7em5535f2f12af96b59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:58424 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab0DUAOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:14:18 -0400
Received: by bwz25 with SMTP id 25so7468824bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 17:14:16 -0700 (PDT)
In-Reply-To: <n2g46c8cb3e1004201657t50599d7em5535f2f12af96b59@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 04:57 +0500, Gaspar Chilingarov a =C3=A9=
crit :
> Ohhh, see my bug report again, please :)
>=20
> The problem arises when used port count is close to or more than the
> number of local ports available on the system (in your case 40000
> client connections is smaller than 51000 of available ports).
>=20
> I think that if you choose to go with default settings and try to bin=
d
> half of your ports to one local IP and half of your ports - to anothe=
r
> one -- you will hit this bug as well.
>=20
> If you explicitly bind to the local ports as well - it _may_ solve a
> problem - I will this today (it's just a workaround, but in fact not
> the solution :), but if you let kernel automatically find local ports
> - you will get the errors.

Yes, I posted a preliminar patch to solve this problem, please test
it ;)

But beware bind(port=3D0) time might be long. This is why high perf
programs prefer to give the exact port at bind(IP, port) time.

Algo will scan the whole range to find the port used by minimum number
of connection. Then it'll check if the selected IP was already in use.

If not -> ok, port found

If yes -> redo five time the same loop (I guess this redo should be
changed too, to use something else.



