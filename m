From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/4] netfilter: use sequence number synchronization for
 counters
Date: Wed, 28 Jan 2009 17:15:25 +0100
Message-ID: <4980849D.3060001@trash.net>
References: <20090127235310.159946902@vyatta.com>	<20090127235508.952787501@vyatta.com>	<497FF860.9080406@cosmosbay.com> <20090127222837.4ea8b255@extreme> <497FFCAE.70503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497FFCAE.70503@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>>>>   --- a/net/ipv4/netfilter/ip_tables.c    2009-01-27=20
>>>> 14:48:41.567879095 -0800
>>>> +++ b/net/ipv4/netfilter/ip_tables.c    2009-01-27=20
>>>> 15:45:05.766673246 -0800
>>>> @@ -366,7 +366,9 @@ ipt_do_table(struct sk_buff *skb,
>>>>              if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) !=3D =
0)
>>>>                  goto no_match;
>>>> =20
>>>> +            write_seqcount_begin(&e->seq);
>>>>              ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
>>>> +            write_seqcount_end(&e->seq);
>>>>        =20
>>> Its not very good to do it like this, (one seqcount_t per rule per =
cpu)
>>>    =20
>>
>> If we use one count per table, that solves it, but it becomes a hot
>> spot, and on an active machine will never settle.
>>
>>  =20
> One seqcount per table and per cpu.
> Only one cpu (the owner) will need to change the seqcount (one increm=
ent=20
> when entering ipt_do_table(), one increment when leaving)

That would also make sure the counters add up, right?

> This location is only read by the thread doing the "iptables -L". We=20
> dont care it spends a few cycles, it's already a big cruncher.

Indeed.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
