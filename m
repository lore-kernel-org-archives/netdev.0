From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix a bug in emitting the 16-bit immediate operand of
 AND
Date: Thu, 29 Mar 2012 18:13:11 -0400 (EDT)
Message-ID: <20120329.181311.91358289912662112.davem@davemloft.net>
References: <4F742AE4.6050006@ict.ac.cn>
	<1333021525.3402.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zhuangfeiran@ict.ac.cn, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab2C2WOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 18:14:21 -0400
In-Reply-To: <1333021525.3402.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Mar 2012 13:45:25 +0200

> Le jeudi 29 mars 2012 =E0 17:27 +0800, zhuangfeiran@ict.ac.cn a =E9cr=
it :
>> When K >=3D 0xFFFF0000, AND needs the two least significant bytes of=
 K as
>> its operand, but EMIT2() gives it the least significant byte of K an=
d
>> 0x2. EMIT() should be used here to replace EMIT2().
>>=20
>> Signed-off-by: Feiran Zhuang  <zhuangfeiran@ict.ac.cn>
>> ---
>>  arch/x86/net/bpf_jit_comp.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>=20
>> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp=
=2Ec
>> index 5671752..5a5b6e4 100644
>> --- a/arch/x86/net/bpf_jit_comp.c
>> +++ b/arch/x86/net/bpf_jit_comp.c
>> @@ -289,7 +289,7 @@ void bpf_jit_compile(struct sk_filter *fp)
>>  					EMIT2(0x24, K & 0xFF); /* and imm8,%al */
>>  				} else if (K >=3D 0xFFFF0000) {
>>  					EMIT2(0x66, 0x25);	/* and imm16,%ax */
>> -					EMIT2(K, 2);
>> +					EMIT(K, 2);
>>  				} else {
>>  					EMIT1_off32(0x25, K);	/* and imm32,%eax */
>>  				}
>=20
> Good catch, thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
