From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: possible issue between bridge igmp/multicast  handling & bnx2x
 on kernel 2.6.34 and >
Date: Wed, 02 Feb 2011 14:29:29 +0100
Message-ID: <4D495C39.6020002@univ-nantes.fr>
References: <4D23234E.30709@univ-nantes.fr>	 <4D26EDA4.7060502@univ-nantes.fr> <1294399705.3306.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:36679 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab1BBN3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 08:29:31 -0500
In-Reply-To: <1294399705.3306.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le vendredi 07 janvier 2011 =C3=A0 11:40 +0100, Yann Dupont a =C3=A9c=
rit :
>> Le 04/01/2011 14:40, Yann Dupont a =C3=A9crit :
>> ...
>>> We just added BCM57711 10G cards (bnx2x driver) on our blade server=
s
>>> (connected to 10G Power Connect M8024).
>>> Since then, we are experiencing random lost of packets.
>>>
>>> Symptom : packets are lost on some vlans for a few seconds, then
>>> things go back to normal (and stops again a few minutes later)
>>>
>> As I didn't had answer so far , I digged a little more and captured =
more
>> packets.
>> I just noticed that an event trigger that problem : IPv6 neighbor
>> discovery packet .
>>
>> This is , of course, a multicast packet.
>>
>> Just saw that 2.6.36.3 should include this fix :
>>
Just a little update, the problem doesn't seem to be what we thought at=
=20
first.

It may not be related to the bnx2x driver after all.
We noticed that we had the same symptoms on target machine using bnx2=20
drivers  (we missed that at first since the outages are way briefer).

We're now rather suspecting our own firewall (also a linux in a kvm=20
machine) since without it we don't get any more problem and the packet=20
drops occurs on _THIS_ network, when packets are routed by _THIS_ firew=
all.

Anyway, all of that is very puzzling, we have made a lot of network=20
dumps and we have really no clue of what's happening there.
We don't understand why, if the problem is really on our firewall=20
machine, setting CONFIG_BRIDGE_IGMP_SNOOPING to 'n' on the target=20
machine efficiently fix the problem, Especially since it doesn't seem=20
related at all with our setup and we don't see anything in our network=20
dumps that could explain this.

It's probably not a single problem, but a sum of different problems.
We continue to search.
Sorry for the noise.

Regards,

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr

