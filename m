From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Thu, 15 Mar 2007 08:42:20 +0100
Message-ID: <45F8F8DC.3010302@cosmosbay.com>
References: <20070312210907.509184287@linux-foundation.org>	<20070315021840.GG1246@kvack.org>	<45F8E793.7040603@cosmosbay.com> <20070315.002516.59485075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bcrl@kvack.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43552 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbXCOHmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 03:42:36 -0400
In-Reply-To: <20070315.002516.59485075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 15 Mar 2007 07:28:35 +0100
>=20
>> One problem with your patch is that all read_always() of pointers ar=
e going to=20
>> use 3 bytes more of code, thus raising icache pressure.
>>
>> 48 b8 c3 08 e8 8c af    mov    $0x71af8ce808c3,%rax
>> 71 00 00
>>
>> instead of %rip relative addressing
>>
>> 48 8b 05 99 f3 09 00    mov    652185(%rip),%rax
>=20
> Could we obtain %rip relative addressing with the ELF
> relocation approach I mentioned?

I dont think so, because 32 bits relative to %rip is not enough to cove=
r all=20
the addresses that a 64bits kernel can use :)

%rip relative addressing works only because all the x86_64 kernel (text=
+=20
static/bss data) are in the 0xffffffff80000000 - fffffffffff00000  2^31=
 quadrant

but vmalloc() range for example  is ffffc20000000000 - ffffe1ffffffffff=
 (45 bits)


