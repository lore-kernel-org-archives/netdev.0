From: David Miller <davem@davemloft.net>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Sun, 18 Sep 2011 21:07:25 -0400 (EDT)
Message-ID: <20110918.210725.2061666096968958448.davem@davemloft.net>
References: <4E696FD0.7060702@intel.com>
	<1316374544.31335.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au, sfr@canb.auug.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab1ISBJg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 21:09:36 -0400
In-Reply-To: <1316374544.31335.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Sep 2011 21:35:44 +0200

> Le vendredi 09 septembre 2011 =E0 09:45 +0800, Yan, Zheng a =E9crit :
>> Hi all,
>>=20
>> I found a check in tcp_is_sackblock_valid() is suspicious. It agains=
t
>> its comment and RFC. I think the correct check should be:
>>=20
>> ---
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 385c470..a5d01b1 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_s=
ock *tp, int is_dsack,
>>                 return 0;
>> =20
>>         /* ...Then it's D-SACK, and must reside below snd_una comple=
tely */
>> -       if (!after(end_seq, tp->snd_una))
>> +       if (after(end_seq, tp->snd_una))
>>                 return 0;
>> =20
>>         if (!before(start_seq, tp->undo_marker))
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This bug was introduced in 2.6.24 by commit 5b3c9882

Yan, please repost this patch with proper commit message and signoffs
so I can apply it, thanks.
