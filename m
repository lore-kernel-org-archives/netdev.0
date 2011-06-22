From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 1/3] net: ipv4: fix potential memory leak by
 assigning uhash_entries
Date: Wed, 22 Jun 2011 10:23:20 -0400
Message-ID: <4E01FAD8.6030106@windriver.com>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>	 <1308689020-1873-2-git-send-email-paul.gortmaker@windriver.com> <1308719087.2713.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mark Asselstine <mark.asselstine@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36937 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073Ab1FVOX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 10:23:28 -0400
In-Reply-To: <1308719087.2713.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-22 01:04 AM, Eric Dumazet wrote:
> Le mardi 21 juin 2011 =C3=A0 16:43 -0400, Paul Gortmaker a =C3=A9crit=
 :

[...]

>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index abca870..6f53a5a 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -2155,7 +2155,7 @@ void udp4_proc_exit(void)
>>  }
>>  #endif /* CONFIG_PROC_FS */
>> =20
>> -static __initdata unsigned long uhash_entries;
>> +static __initdata unsigned long uhash_entries =3D UDP_HTABLE_SIZE_M=
IN;
>>  static int __init set_uhash_entries(char *str)
>>  {
>>  	if (!str)
>=20
> Arg no, I really wanted to get more hash slots in my 32bit machines,
> with 4Gbytes of memory.
>=20
> Here is what I currently have (without your patch)
>=20
> [    1.903086] UDP hash table entries: 512 (order: 2, 16384 bytes)
>=20
>=20
> I mean, this kmemleak was already reported.

Ah, I'd not read that thread - here is the link if anyone else
is following along:

http://lists-archives.org/linux-kernel/27460513-kmemleak-for-mips.html

>=20
> 32MB machines are things of the past.
>=20
> If you really care, please add a change to alloc_large_system_hash() =
?

Given the user list (dcache.c, inode.c, pid.c, ...) it probably
isn't worth the churn of adding a min argument to the calls.
I'm fine with dropping this patch (and glad I'd CC'd you on it)

Thanks,
Paul.

>=20
>=20
>=20
