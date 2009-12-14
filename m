From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 06:56:31 +0100
Message-ID: <4B25D38F.1090702@gmail.com>
References: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de> <20091212.010340.227842186.davem@davemloft.net> <4B2360BF.5000102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35844 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbZLNF4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 00:56:37 -0500
In-Reply-To: <4B2360BF.5000102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2009 10:22, Eric Dumazet a =E9crit :
> Le 12/12/2009 10:03, David Miller a =E9crit :
>> From: Christian Kujau <lists@nerdbynature.de>
>> Date: Fri, 11 Dec 2009 23:43:10 -0800 (PST)
>>
>>> today I upgraded from 2.6.32-rc7 to the latest -git (mainline) and =
after a=20
>>> few hours the messages below appeared in the log. Apparently "privo=
xy" was=20
>>> very busy handling connections, but the messages never appeared wit=
h=20
>>> earlier kernels.=20
>>>
>>> Full dmesg & .config is on:
>>> http://nerdbynature.de/bits/2.6.33-git/inet_accept/
>>
>> Yeah I started seeing this on one of my machines too, the
>> assertion is:
>>
>> 	WARN_ON(newsk->sk_state =3D=3D TCP_SYN_RECV);
>>
>> I wonder if some of the refactorings we did to allow per-route
>> SACK/DSACK/etc. controls messed some sequence of state changes
>> on TCP sockets.  But I can't find anything obvious in those
>> commits.
>=20
> Could it be about syncookies patches ?
>=20
> tcp_create_openreq_child() changes ?
>=20

It seems to me tcp_create_openreq_child() doesnt properly initialize
newtp->cookie_values to NULL, but this should not produce warnings like=
 that ?

Sorry to not provides a proper patch now, I have to run...

