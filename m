From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Wed, 01 Jul 2009 01:31:09 +0200
Message-ID: <4A4AA03D.5090808@itcare.pl>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jarek Poplawski <jarkao2@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:33238 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454AbZF3XbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 19:31:08 -0400
In-Reply-To: <20090630204141.GB3026@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Tue, Jun 30, 2009 at 10:16:57PM +0200, Pawe=B3 Staszewski wrote:
>  =20
>> Jarek Poplawski pisze:
>>    =20
>>> On Mon, Jun 29, 2009 at 10:47:03AM +0000, Jarek Poplawski wrote:
>>>  =20
>>>      =20
>>>> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote=
:
>>>>    =20
>>>>        =20
>>>>> I apply this patch
>>>>>
>>>>> fib_triestats in attached file :)
>>>>>      =20
>>>>>          =20
>>>> Great! But it would be nice to check if this (accidentally ;-) mig=
ht
>>>> fix the previous problem, so I attach below the patch with "manual
>>>> RCU", which btw. (or even more important) should verify RCU use he=
re.
>>>>
>>>> It should be applied on top of this last "Fix..., part3". And
>>>> again: it's quite probable it can fail, so with caution, no hurry
>>>> (it can wait for quiet time)...
>>>>    =20
>>>>        =20
>>> Pawel, here is another try to check what's going on here, so just
>>> like before, but this one on top of these 2 last working patches,
>>> plus quite time... (Stats aren't necessary; if these are some doubt=
s
>>> let me know.)
>>>
>>> Thanks,
>>> Jarek P.
>>> --------------------> (synchronize_rcu take 5)
>>>
>>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>> --- a/net/ipv4/fib_trie.c	2009-06-29 10:00:14.000000000 +0000
>>> +++ b/net/ipv4/fib_trie.c	2009-06-30 06:50:35.000000000 +0000
>>> @@ -1036,6 +1036,7 @@ static void trie_rebalance(struct trie *
>>>   	rcu_assign_pointer(t->trie, (struct node *)tn);
>>>  	tnode_free_flush();
>>> +	synchronize_rcu();
>>>   	return;
>>>  }
>>>  =20
>>>      =20
>> Apply and tested
>>
>> Traffic is not forwarded after apply this patch.:)
>>    =20
>
> A little comment: these last 2 patches weren't exactly to fix the
> problem you reported, which should be mostly fixed by the earlier
> patch.
>
> There is some other bug, which you omit with CONFIG_PREEMPT_NONE
> (but it's not for sure there is no by effects). So, I'd like to be
> sure you are willing and can (without too much risk) to do more such
> tests. Alas I've no way to generate similar conditions so it would
> simply have to wait for somebody else.
>
>  =20
Yes i can make tests like this.
My network is splited to test clients and other normal clients
so it's really no problem to make testing. - if testing clients working=
=20
then traffic from normal clients is also switched to this router (but i=
f=20
traffic is not forwarded "like in this case" for testing clients then=20
failover switching them to working router )

and other point to make this tests - is that - it is good to have all i=
n=20
linux kernel networking working well :)

Regards
Pawe=B3 Staszewski

> Many thanks again,
> Jarek P.
>
>
>  =20

