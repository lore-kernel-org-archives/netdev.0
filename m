From: John Williams <john.williams@petalogix.com>
Subject: Re: [microblaze-uclinux] Re: [PATCH net-next-2.6] net: Increase
	NET_SKB_PAD to 64 bytes
Date: Fri, 7 May 2010 15:28:08 +1000
Message-ID: <m2g1d3f23371005062228y267b398cue82f518c7638929e@mail.gmail.com>
References: <1273037049.2304.7.camel@edumazet-laptop>
	 <20100506.220221.90798296.davem@davemloft.net>
	 <1273209321.2222.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com, monstr@monstr.eu
To: microblaze-uclinux@itee.uq.edu.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63368 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab0EGF2K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:28:10 -0400
Received: by vws18 with SMTP id 18so487559vws.19
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 22:28:09 -0700 (PDT)
In-Reply-To: <1273209321.2222.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 7, 2010 at 3:15 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 06 mai 2010 =E0 22:02 -0700, David Miller a =E9crit :
>
>> Seeing this made me go check who was overriding NET_IP_ALIGN or
>> NET_SKB_PAD.
>>
>> The powerpc bits are legitimate, but the microblaze case is complete
>> bogosity. =A0It defines NET_IP_ALIGN to the default (2) and sets
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
>> =A0arch/microblaze/include/asm/system.h | =A0 10 ----------
>> =A01 files changed, 0 insertions(+), 10 deletions(-)
>>
>> diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/=
include/asm/system.h
>> index 48c4f03..b1e2f07 100644
>> --- a/arch/microblaze/include/asm/system.h
>> +++ b/arch/microblaze/include/asm/system.h
>> @@ -97,14 +97,4 @@ extern struct dentry *of_debugfs_root;
>>
>> =A0#define arch_align_stack(x) (x)
>>
>> -/*
>> - * MicroBlaze doesn't handle unaligned accesses in hardware.
>> - *
>> - * Based on this we force the IP header alignment in network driver=
s.
>> - * We also modify NET_SKB_PAD to be a cacheline in size, thus maint=
aining
>> - * cacheline alignment of buffers.
>> - */
>> -#define NET_IP_ALIGN 2
>> -#define NET_SKB_PAD =A0L1_CACHE_BYTES
>> -
>> =A0#endif /* _ASM_MICROBLAZE_SYSTEM_H */
>
> Yes, this seems strange it actually worked if L1_CACHE_BYTES =3D 4

There will be some patches coming from Michal that cleans all of this
up - MicroBlaze has a configurable cacheline length, we have some
patches that set this to the longest possible (32 bytes) in a
conservative assumption.

John
