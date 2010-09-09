From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Thu, 09 Sep 2010 14:38:27 -0700
Message-ID: <4C8953D3.9060204@hp.com>
References: <1284065105.4782.11.camel@edumazet-laptop>	<4C894FBD.2020109@ans.pl> <20100909.143001.104050644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ole@ans.pl, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:11736 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab0IIVia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 17:38:30 -0400
In-Reply-To: <20100909.143001.104050644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Krzysztof Ol=C4=99dzki <ole@ans.pl>
> Date: Thu, 09 Sep 2010 23:21:01 +0200
>=20
>=20
>>On 2010-09-09 22:45, Eric Dumazet wrote:
>>
>>>Problem is : With 16 RX queues per device , thats 4078*16*2Kbytes pe=
r
>>>ethernet port.
>>>
>>>Total :
>>>
>>>skbuff_head_cache 130747 131025 256 15 1 : tunables 120 60 8 :
>>>slabdata 8735 8735 40
>>>size-2048 130866 130888 2048 2 1 : tunables 24 12 8 : slabdata 65444
>>>65444 28
>>>
>>>Thats about 300 Mbytes of memory, just in case some network trafic
>>>will occur.
>>>
>>>Lets do something about that ?
>>
>>Yep, it is ~8MB per queue, not so much alone, but a lot together. For
>>this reason I use something like bnx2.num_queues=3D2 on servers where=
 I
>>don't need much CPU power for network workload.
>=20
>=20
> I think simply that the RX queue size should be scaled by the number
> of queues we have.
>=20
> If people want enormous RX ring sizes even when there are many queues=
,
> they can use ethtool to get that.
>=20
> Taking up 130MB of memory per-card, just for RX packet buffers, is
> certainly over the top.

It gets even better if one consideres JumboFrames...  that said, I've h=
ad=20
customer contacts (indirect) where they were quite keep to have a ring =
size of=20
at least 2048 packets - I never could get it confirmed, but I suspect t=
hey had=20
applications/systems that might "go out to lunch" for long-enough perio=
ds of=20
time they wanted that degree of FIFO.

Doesn't necessarily change "what should be the defaults" much but there=
 it is.

rick jones
