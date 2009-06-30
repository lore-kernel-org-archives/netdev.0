From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Tue, 30 Jun 2009 22:41:42 +0200
Message-ID: <20090630204141.GB3026@ami.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:64240 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898AbZF3UmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 16:42:08 -0400
Received: by fxm18 with SMTP id 18so406147fxm.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 13:42:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4A72B9.3030400@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 10:16:57PM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
>> On Mon, Jun 29, 2009 at 10:47:03AM +0000, Jarek Poplawski wrote:
>>  =20
>>> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
>>>    =20
>>>> I apply this patch
>>>>
>>>> fib_triestats in attached file :)
>>>>      =20
>>> Great! But it would be nice to check if this (accidentally ;-) migh=
t
>>> fix the previous problem, so I attach below the patch with "manual
>>> RCU", which btw. (or even more important) should verify RCU use her=
e.
>>>
>>> It should be applied on top of this last "Fix..., part3". And
>>> again: it's quite probable it can fail, so with caution, no hurry
>>> (it can wait for quiet time)...
>>>    =20
>>
>> Pawel, here is another try to check what's going on here, so just
>> like before, but this one on top of these 2 last working patches,
>> plus quite time... (Stats aren't necessary; if these are some doubts
>> let me know.)
>>
>> Thanks,
>> Jarek P.
>> --------------------> (synchronize_rcu take 5)
>>
>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> --- a/net/ipv4/fib_trie.c	2009-06-29 10:00:14.000000000 +0000
>> +++ b/net/ipv4/fib_trie.c	2009-06-30 06:50:35.000000000 +0000
>> @@ -1036,6 +1036,7 @@ static void trie_rebalance(struct trie *
>>   	rcu_assign_pointer(t->trie, (struct node *)tn);
>>  	tnode_free_flush();
>> +	synchronize_rcu();
>>   	return;
>>  }
>>  =20
>
> Apply and tested
>
> Traffic is not forwarded after apply this patch.:)

A little comment: these last 2 patches weren't exactly to fix the
problem you reported, which should be mostly fixed by the earlier
patch.

There is some other bug, which you omit with CONFIG_PREEMPT_NONE
(but it's not for sure there is no by effects). So, I'd like to be
sure you are willing and can (without too much risk) to do more such
tests. Alas I've no way to generate similar conditions so it would
simply have to wait for somebody else.

Many thanks again,
Jarek P.
