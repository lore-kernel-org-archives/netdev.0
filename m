From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 17:11:59 +0800
Message-ID: <CAJFZqHzFvspqFyZuZsTSyOOKdCq7SS=xMY5hH3kycaqO+=bXGw@mail.gmail.com>
References: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
	<alpine.LFD.2.00.1212191001530.1620@ja.ssi.bg>
	<CAJFZqHyhMS22pKuW50D0uZLA5-WDUYBEZurPGCW6gSyRY-6JHg@mail.gmail.com>
	<alpine.LFD.2.00.1212191051590.1906@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:39394 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2LSJRN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:17:13 -0500
Received: by mail-vc0-f176.google.com with SMTP id fo13so1999286vcb.21
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:17:13 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1212191051590.1906@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/19 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Wed, 19 Dec 2012, RongQing Li wrote:
>
>> >>  static inline int IP_ECN_set_ce(struct iphdr *iph)
>> >>  {
>> >> -     u32 check =3D (__force u32)iph->check;
>> >> -     u32 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
>> >> -
>> >> -     /*
>> >> -      * After the last operation we have (in binary):
>> >> -      * INET_ECN_NOT_ECT =3D> 01
>> >> -      * INET_ECN_ECT_1   =3D> 10
>> >> -      * INET_ECN_ECT_0   =3D> 11
>> >> -      * INET_ECN_CE      =3D> 00
>> >> -      */
>> >
>> >         I think, the above comment explains how an
>> > increment (iph->tos + 1) serves the purpose to check
>> > for ECT_1 and ECT_0, there is no such thing as
>> > addressing the next byte from header. It is just an
>> > optimized logic that avoids complex INET_ECN_is_XXX
>> > checks.
>> Thanks for your reply.
>> Do you mean this comment are valuable?
>
>         It looks better to me with the comment and the
> original checks. But I can't comment the correctness of
> the other changes in your patch.

I do not know how they are useful, and how the original check
works, since the value in comments are wrong, the correct is:

enum {
        INET_ECN_NOT_ECT =3D 0,
        INET_ECN_ECT_1 =3D 1,
        INET_ECN_ECT_0 =3D 2,
        INET_ECN_CE =3D 3,
        INET_ECN_MASK =3D 3,
};


   00: Non ECN-Capable Transport =97 Non-ECT
    10: ECN Capable Transport =97 ECT(0)
    01: ECN Capable Transport =97 ECT(1)
    11: Congestion Encountered =97 CE

-Roy


>
>> >> -     if (!(ecn & 2))
>> >> +     u32 ecn =3D iph->tos & INET_ECN_MASK;
>> >> +
>> >> +     if (INET_ECN_is_ce(ecn) || INET_ECN_is_not_ect(ecn))
>> >>               return !ecn;
>> >
>> >         May be return INET_ECN_is_ce(ecn) ?
>> >
>>
>> I like to set the return value to void, since noone cares about the
>> return value.
>
>         It is used by INET_ECN_set_ce and its users in
> net/sched/
>
>> -Roy
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
