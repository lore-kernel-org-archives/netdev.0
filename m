From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Sat, 12 Dec 2009 10:22:07 +0100
Message-ID: <4B2360BF.5000102@gmail.com>
References: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de> <20091212.010340.227842186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759054AbZLLJWJ@vger.kernel.org>
In-Reply-To: <20091212.010340.227842186.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/12/2009 10:03, David Miller a =E9crit :
> From: Christian Kujau <lists@nerdbynature.de>
> Date: Fri, 11 Dec 2009 23:43:10 -0800 (PST)
>=20
>> today I upgraded from 2.6.32-rc7 to the latest -git (mainline) and a=
fter a=20
>> few hours the messages below appeared in the log. Apparently "privox=
y" was=20
>> very busy handling connections, but the messages never appeared with=
=20
>> earlier kernels.=20
>>
>> Full dmesg & .config is on:
>> http://nerdbynature.de/bits/2.6.33-git/inet_accept/
>=20
> Yeah I started seeing this on one of my machines too, the
> assertion is:
>=20
> 	WARN_ON(newsk->sk_state =3D=3D TCP_SYN_RECV);
>=20
> I wonder if some of the refactorings we did to allow per-route
> SACK/DSACK/etc. controls messed some sequence of state changes
> on TCP sockets.  But I can't find anything obvious in those
> commits.

Could it be about syncookies patches ?

tcp_create_openreq_child() changes ?
