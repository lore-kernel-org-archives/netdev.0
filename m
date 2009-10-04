From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: restore nanosec delays
Date: Sun, 04 Oct 2009 08:45:12 +0200
Message-ID: <4AC84478.3010102@gmail.com>
References: <4AC737E6.1050809@gmail.com> <20091003211620.4ac469b6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52696 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbZJDGp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2009 02:45:56 -0400
In-Reply-To: <20091003211620.4ac469b6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Sat, 03 Oct 2009 13:39:18 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Commit fd29cf72 (pktgen: convert to use ktime_t)
>> inadvertantly converted "delay" parameter from nanosec to microsec.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>
>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index b694552..227ba31 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -964,7 +964,7 @@ static ssize_t pktgen_if_write(struct file *file=
,
>>  		if (value =3D=3D 0x7FFFFFFF)
>>  			pkt_dev->delay =3D ULLONG_MAX;
>>  		else
>> -			pkt_dev->delay =3D (u64)value * NSEC_PER_USEC;
>> +			pkt_dev->delay =3D (u64)value;
>=20
> Is the cast really necessary?

It reminds us 'value' is 32 bits, but it's not necessary, as C compiler
can silently do the cast.

