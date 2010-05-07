From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 09:53:48 +0200
Message-ID: <4BE3C70C.4060705@monstr.eu>
References: <1273037049.2304.7.camel@edumazet-laptop>	 <20100506.220221.90798296.davem@davemloft.net> <1273209321.2222.36.camel@edumazet-laptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com,
	microblaze-uclinux@itee.uq.edu.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:20988 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab0EGHy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 03:54:26 -0400
Received: by fg-out-1718.google.com with SMTP id d23so647092fga.1
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 00:54:24 -0700 (PDT)
In-Reply-To: <1273209321.2222.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 06 mai 2010 =E0 22:02 -0700, David Miller a =E9crit :
>=20
>> Seeing this made me go check who was overriding NET_IP_ALIGN or
>> NET_SKB_PAD.
>>
>> The powerpc bits are legitimate, but the microblaze case is complete
>> bogosity.  It defines NET_IP_ALIGN to the default (2) and sets
>> NET_SKB_PAD to L1_CACHE_BYTES which on microblaze is 4 and
>> significantly smaller than the default.
>>
>> So I'm going to delete them in net-next-2.6 like so:
>>
>> --------------------
>> microblaze: Kill NET_SKB_PAD and NET_IP_ALIGN overrides.
>>
>> NET_IP_ALIGN defaults to 2, no need to override.
>>
>> NET_SKB_PAD is now 64, which is much larger than microblaze's
>> L1_CACHE_SIZE so no need to override that either.
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  arch/microblaze/include/asm/system.h |   10 ----------
>>  1 files changed, 0 insertions(+), 10 deletions(-)
>>
>> diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/=
include/asm/system.h
>> index 48c4f03..b1e2f07 100644
>> --- a/arch/microblaze/include/asm/system.h
>> +++ b/arch/microblaze/include/asm/system.h
>> @@ -97,14 +97,4 @@ extern struct dentry *of_debugfs_root;
>> =20
>>  #define arch_align_stack(x) (x)
>> =20
>> -/*
>> - * MicroBlaze doesn't handle unaligned accesses in hardware.
>> - *
>> - * Based on this we force the IP header alignment in network driver=
s.
>> - * We also modify NET_SKB_PAD to be a cacheline in size, thus maint=
aining
>> - * cacheline alignment of buffers.
>> - */
>> -#define NET_IP_ALIGN	2
>> -#define NET_SKB_PAD	L1_CACHE_BYTES
>> -
>>  #endif /* _ASM_MICROBLAZE_SYSTEM_H */
>=20
> Yes, this seems strange it actually worked if L1_CACHE_BYTES =3D 4

This was fault which I fixed. I sent pull request to Linus yesterday=20
with contains patch which fix it.
L1_CACHE_BYTES was setup to 32 which is maximum cache line length on=20
Microblaze.

I will add this Microblaze patch to my repo for testing and anyway=20
should go through my repo.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
