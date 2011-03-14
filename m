From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: possible issue between bridge igmp/multicast  handling & bnx2x
 on kernel 2.6.34 and >
Date: Mon, 14 Mar 2011 11:40:28 +0100
Message-ID: <4D7DF09C.9000400@univ-nantes.fr>
References: <4D23234E.30709@univ-nantes.fr>	 <4D26EDA4.7060502@univ-nantes.fr> <1294399705.3306.8.camel@edumazet-laptop> <4D495C39.6020002@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:44976 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab1CNKuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:50:15 -0400
In-Reply-To: <4D495C39.6020002@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/02/2011 14:29, Yann Dupont a =C3=A9crit :
>> Le vendredi 07 janvier 2011 =C3=A0 11:40 +0100, Yann Dupont a =C3=A9=
crit :
>>> Le 04/01/2011 14:40, Yann Dupont a =C3=A9crit :
>>> ...
>>>> We just added BCM57711 10G cards (bnx2x driver) on our blade serve=
rs
>>>> (connected to 10G Power Connect M8024).
>>>> Since then, we are experiencing random lost of packets.
>>>>
>>>> Symptom : packets are lost on some vlans for a few seconds, then
>>>> things go back to normal (and stops again a few minutes later)
>>>>
>>> As I didn't had answer so far , I digged a little more and captured=
=20
>>> more
>>> packets.
>>> I just noticed that an event trigger that problem : IPv6 neighbor
>>> discovery packet .
>>>
>>> This is , of course, a multicast packet.
>>>
>>> Just saw that 2.6.36.3 should include this fix :
>>>
> Just a little update, the problem doesn't seem to be what we thought=20
> at first.
>
> It may not be related to the bnx2x driver after all.
> We noticed that we had the same symptoms on target machine using bnx2=
=20
> drivers  (we missed that at first since the outages are way briefer).
>
> We're now rather suspecting our own firewall (also a linux in a kvm=20
> machine) since without it we don't get any more problem and the packe=
t=20
> drops occurs on _THIS_ network, when packets are routed by _THIS_=20
> firewall.
>
> Anyway, all of that is very puzzling, we have made a lot of network=20
> dumps and we have really no clue of what's happening there.
> We don't understand why, if the problem is really on our firewall=20
> machine, setting CONFIG_BRIDGE_IGMP_SNOOPING to 'n' on the target=20
> machine efficiently fix the problem, Especially since it doesn't seem=
=20
> related at all with our setup and we don't see anything in our networ=
k=20
> dumps that could explain this.
>
> It's probably not a single problem, but a sum of different problems.
> We continue to search.
> Sorry for the noise.
>
> Regards,
>
One of my collegue noticied that :

https://lists.linux-foundation.org/pipermail/bridge/2010-October/007362=
=2Ehtml

Exact same problem.
In fact, the problem **really** seems to be on the network switch.

Our servers are DELL M605 on a DELL M1000e chassis, with powerconnect=20
M6220 (G) and  M8024 (10G)

IGMP snooping is also activated on those switches. If we turn igmp=20
snooping off on M8024 for exemple, we don't have problems anymore, that=
=20
is, we can activate IGMP snooping ON the linux bridge without loosing=20
packets.

M6220 & M8024 seems concerned. Time to make a bug report (again and=20
again...if you ask me, I can tell you they are crap.)

Sorry for the noise,

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr

