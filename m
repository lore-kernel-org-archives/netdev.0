From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in
 arp_packet_match()
Date: Tue, 24 Mar 2009 22:52:26 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903242243040.3974@fbirervta.pbzchgretzou.qr>
References: <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com> <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr> <20090324.141848.119353425.davem@davemloft.net> <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr>
 <49C952FE.7070202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C952FE.7070202@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2009-03-24 22:39, Eric Dumazet wrote:
>>> memcmp() can't make any assumptions about alignment.
>>> Whereas we _know_ this thing is exactly 16-bit aligned.
>>>
>>> All of the optimized memcmp() implementations look for
>>> 32-bit alignment and punt to byte at a time comparison
>>> loops if things are not aligned enough.
>> 
>> Yes, I seem to remember glibc doing something like
>> [...]
>> Is the cost of testing for non-4-divisibility expensive enough
>> to warrant not usnig memcmp?
>> 
>> Irrespective of all that, I think putting the interface comparison
>> code should be agglomerated in a function/header so that it is
>> replicated across iptables, ip6tables, ebtables, arptables, etc.
>
>memcmp() is fine, but how is it solving the masking problem we have ?

You are right; we would have to calculate the prefix length of the
mask first. (And I think we can assume that there will not be any 1s
in the mask after the first 0.) It would consume CPU indeed.

>Also in the case of arp_tables, _a is long word aligned, while _b and _mask
>are not.
>
>If you look various ifname_compare(), we have two different implementations.
>
>So yes, a factorization is possible for three ip_tables.c, ip6_tables.c and
> xt_physdev.c.

Very well.
