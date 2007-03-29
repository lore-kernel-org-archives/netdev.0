From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Thu, 29 Mar 2007 21:24:31 +0200
Message-ID: <460C126F.7050303@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu> <460064C6.5030302@cosmosbay.com> <4601ADD8.8040500@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta01.mail.t-online.hu ([195.228.240.50]:50184 "EHLO
	mta01.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934330AbXC2TYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 15:24:09 -0400
In-Reply-To: <4601ADD8.8040500@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for the patch. I almost dare not confess that I don't know which=
=20
version to apply to. I tried 3 different ones (2.6.19-r5-gentoo,=20
2.6.20.1 and 2.6.21-rc4), but in the best case at least two hunks=20
failed. Nevertheless, I applied the patches manually. In each case, UDP=
=20
stopped working. I guess, you checked the patch and worked. I don't=20
think I made a mistake in the manual copy, and it seems unlikely that=20
your patch interfered with other parallel changes in the kernel - but,=20
I'm just guessing ...
I think, I'd better send you the spec and code, as you suggested that=20
first we have a common understanding of the issue. I must have failed i=
n=20
passing the point. I'm removing irrelevant stuff, and I send it to you=20
as soon as I can (sorry for my long delays).

thx a lot,
Zacco

Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
>> Currently, udp_hash[UDP_HTABLE_SIZE] is using a hash function based=20
>> on dport number only.
>>
>> In your case, as you use a single port value, all sockets are in a=20
>> single slot of this hash table :
>> To find the good socket, __udp4_lib_lookup() has to search in a list=
=20
>> with thousands of elements. Not that good, isnt it ? :(
>
> In case you want to try, here is a patch that could help you :)
>
> [PATCH] INET : IPV4 UDP lookups converted to a 2 pass algo
>
> Some people want to have many UDP sockets, binded to a single port bu=
t=20
> many different addresses. We currently hash all those sockets into a=20
> single chain. Processing of incoming packets is very expensive,=20
> because the whole chain must be examined to find the best match.
>
> I chose in this patch to hash UDP sockets with a hash function that=20
> take into account both their port number and address : This has a=20
> drawback because we need two lookups : one with a given address, one=20
> with a wildcard (null) address.
>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>

