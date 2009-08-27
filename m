From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 16:17:10 +0200
Message-ID: <4A969566.3070606@gmail.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com>	<4A93E36C.8070502@gmail.com>	<0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>	<4A967FCE.3000807@gmail.com> <87skfdl6qt.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li_Xin2@emc.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40380 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbZH0ORR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 10:17:17 -0400
In-Reply-To: <87skfdl6qt.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> Now, 7200 seconds might be inappropriate for special needs, and cons=
idering
>> there is no way to change tcp_retries2 for a given socket (only choi=
ce being the global
>> tcp_retries2 setting), I would vote for a change in our stack, to *r=
elax* RFC,
>> and get smaller keepalive timers if possible.
>=20
> I think the better fix would be to just to only do that when
> tcp_retries2 > keep alive time. So keep the existing behaviour
> with default keep alive, but switch when the user defined
> a very short keep alive.
>=20

tcp_retries2 is a number of retries, its difficult to derive a time fro=
m it.

Also, it's not clear what behavior you are refering to.
Imagine we can be smart and compute tcp_retries2_time (in jiffies) from=
 tcp_retries2
If keepalive_timer fires and we have packets in flight, what heuristic =
do you suggest ?

if (tp->packets_out || tcp_send_head(sk))
	if (tcp_retries2_time < keepalive_time_when(tp))
		goto resched;
elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
=2E..

What would be the gain ?
Arming timer exactly every keepalive_time_when(tp)
instead of keepalive_time_when(tp) - (tcp_time_stamp - tp->rcv_tstamp) =
?

