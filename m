From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 01:31:18 -0800 (PST)
Message-ID: <20121219.013118.1350511712183464079.davem@davemloft.net>
References: <CAJFZqHyhMS22pKuW50D0uZLA5-WDUYBEZurPGCW6gSyRY-6JHg@mail.gmail.com>
	<alpine.LFD.2.00.1212191051590.1906@ja.ssi.bg>
	<CAJFZqHzFvspqFyZuZsTSyOOKdCq7SS=xMY5hH3kycaqO+=bXGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab2LSJbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:31:19 -0500
In-Reply-To: <CAJFZqHzFvspqFyZuZsTSyOOKdCq7SS=xMY5hH3kycaqO+=bXGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing Li <roy.qing.li@gmail.com>
Date: Wed, 19 Dec 2012 17:11:59 +0800

> 2012/12/19 Julian Anastasov <ja@ssi.bg>:
>>
>>         Hello,
>>
>> On Wed, 19 Dec 2012, RongQing Li wrote:
>>
>>> >>  static inline int IP_ECN_set_ce(struct iphdr *iph)
>>> >>  {
>>> >> -     u32 check = (__force u32)iph->check;
>>> >> -     u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
>>> >> -
>>> >> -     /*
>>> >> -      * After the last operation we have (in binary):
>>> >> -      * INET_ECN_NOT_ECT => 01
>>> >> -      * INET_ECN_ECT_1   => 10
>>> >> -      * INET_ECN_ECT_0   => 11
>>> >> -      * INET_ECN_CE      => 00
>>> >> -      */
>>> >
>>> >         I think, the above comment explains how an
>>> > increment (iph->tos + 1) serves the purpose to check
>>> > for ECT_1 and ECT_0, there is no such thing as
>>> > addressing the next byte from header. It is just an
>>> > optimized logic that avoids complex INET_ECN_is_XXX
>>> > checks.
>>> Thanks for your reply.
>>> Do you mean this comment are valuable?
>>
>>         It looks better to me with the comment and the
>> original checks. But I can't comment the correctness of
>> the other changes in your patch.
> 
> I do not know how they are useful, and how the original check
> works, since the value in comments are wrong, the correct is:
> 
> enum {
>         INET_ECN_NOT_ECT = 0,
>         INET_ECN_ECT_1 = 1,
>         INET_ECN_ECT_0 = 2,
>         INET_ECN_CE = 3,
>         INET_ECN_MASK = 3,
> };
> 
> 
>    00: Non ECN-Capable Transport ― Non-ECT
>     10: ECN Capable Transport ― ECT(0)
>     01: ECN Capable Transport ― ECT(1)
>     11: Congestion Encountered ― CE

You really don't understand the comment, it is saying what
the incremented value corresponds to, ECN wise.

If iph->tos + 1 is 01, we had INET_ECN_NOT_ECT in iph->tos to
begine with, and so on an so forth.

Because you are having so much trouble with this most fundamental
aspect of this code, I have zero confidence in your being able to
make reasonable changes here.

I am not applying this patch.
