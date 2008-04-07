From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Mon, 07 Apr 2008 17:36:59 +0200
Message-ID: <47FA3F9B.6040303@cosmosbay.com>
References: <20080401172702.094c0700@extreme> <47F33D42.9080302@cosmosbay.com> <47F39998.8040605@cosmosbay.com> <20080402110335.66b04181@extreme> <47F3E031.1030806@cosmosbay.com> <20080404090257.2ec38b0c@extreme> <18425.50538.876583.892728@robur.slu.se> <87bq4mrt9v.fsf@basil.nowhere.org> <18426.13019.345218.79888@robur.slu.se> <20080407151503.GD16647@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.18]:45612 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804AbYDGPhT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 11:37:19 -0400
In-Reply-To: <20080407151503.GD16647@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> On Mon, Apr 07, 2008 at 04:42:35PM +0200, Robert Olsson wrote:
>  =20
>> Andi Kleen writes:
>>
>>  > >  Do we get slower with vmalloc due to TLB-lookups etc? Guess th=
is
>>  > >  should be investigated.
>>  >=20
>>  > In some cases it might even go faster because a lot of x86 CPUs
>>  > have far more 4K TLBs than 2M TLBs. vmalloc is just quite expensi=
ve
>>  > in setup/free time, but that shouldn't be a big issue here.
>>
>>
>>  I've did some rDoS testing and the lookup performance is the same o=
r=20
>>  slightly better. So it should be fine. =20
>>    =20
>
> If you want more realistic worst case numbers run something in user s=
pace in=20
> the background that thrashes the TLBs constantly and then see how
> the numbers change.
>
> The main advantage of using large pages is that they tend to be separ=
ated
> from 4K TLBs and since most user space doesn't use large pages it=20
> gives the kernel an effective private TLB pool.
>
> With vmalloc it will now compete with whatever other TLB pigs are act=
ive.
>  =20
Yes, but with vmalloc(), NUMA machines have some chance to distribute=20
this big area on several nodes

(only if the process currently expanding the fib_trie root node has an=20
appropriate numa_policy.... ah well :) :) )




