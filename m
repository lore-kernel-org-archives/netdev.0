From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Thu, 09 Sep 2010 14:30:01 -0700 (PDT)
Message-ID: <20100909.143001.104050644.davem@davemloft.net>
References: <1284065105.4782.11.camel@edumazet-laptop>
	<4C894FBD.2020109@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, eilong@broadcom.com
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753111Ab0IIV3n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 17:29:43 -0400
In-Reply-To: <4C894FBD.2020109@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ol=EAdzki <ole@ans.pl>
Date: Thu, 09 Sep 2010 23:21:01 +0200

> On 2010-09-09 22:45, Eric Dumazet wrote:
>> Problem is : With 16 RX queues per device , thats 4078*16*2Kbytes pe=
r
>> ethernet port.
>>
>> Total :
>>
>> skbuff_head_cache 130747 131025 256 15 1 : tunables 120 60 8 :
>> slabdata 8735 8735 40
>> size-2048 130866 130888 2048 2 1 : tunables 24 12 8 : slabdata 65444
>> 65444 28
>>
>> Thats about 300 Mbytes of memory, just in case some network trafic
>> will occur.
>>
>> Lets do something about that ?
>=20
> Yep, it is ~8MB per queue, not so much alone, but a lot together. For
> this reason I use something like bnx2.num_queues=3D2 on servers where=
 I
> don't need much CPU power for network workload.

I think simply that the RX queue size should be scaled by the number
of queues we have.

If people want enormous RX ring sizes even when there are many queues,
they can use ethtool to get that.

Taking up 130MB of memory per-card, just for RX packet buffers, is
certainly over the top.
