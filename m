From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 06 Dec 2011 10:20:57 -0800
Message-ID: <4EDE5D09.1060404@hp.com>
References: <03369d06-ee52-4eef-a8b6-5a21e6d56840@jasiiieee> <1323161496.2448.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:2712 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab1LFSVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:21:01 -0500
In-Reply-To: <1323161496.2448.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2011 12:51 AM, Eric Dumazet wrote:
> Le mardi 06 d=C3=A9cembre 2011 =C3=A0 03:39 -0500, John A. Sullivan I=
II a =C3=A9crit :
>
>>> ifconfig eth2 txqueuelen 0
>>> tc qdisc add dev eth2 root pfifo
>>> tc qdisc del dev eth2 root
>>>
>>>
>>>
>>>
>> Really? I didn't know one could do that.  Thanks.  However, with no
>> queue length, do I have a significant risk of dropping packets? To
>> answer your other response's question, these are Intel quad port e10=
00
>> cards.  We are frequently pushing them to near line speed so
>> 1,000,000,000 / 1534 / 8 =3D 81,486 pps - John
>
> You can remove qdisc layer, since NIC itself has a TX ring queue
>
> (check exact value with ethtool -g ethX)
>
> # ethtool -g eth2
> Ring parameters for eth2:
> Pre-set maximums:
> RX:		4078
> RX Mini:	0
> RX Jumbo:	0
> TX:		4078
> Current hardware settings:
> RX:		254
> RX Mini:	0
> RX Jumbo:	0
> TX:		4078      ---- HERE ----

And while you are down at the NIC, if every microsecond is precious (no=
=20
matter how close to epsilon compared to the latencies of spinning rust=20
:) you might consider disabling interrupt coalescing via ethtool -C.

rick jones
