From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [rfc] suspicious indentation in do_tcp_setsockopt
Date: Thu, 5 Sep 2013 13:24:51 -0400
Message-ID: <CADVnQy=RuwyiBFmpLpoR4s=5HM70KiggitnK+tG6q2x2=3JaEw@mail.gmail.com>
References: <20130905042045.GD15824@redhat.com>
	<1378356196.1787.74.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Jones <davej@redhat.com>, Yuchung Cheng <ycheng@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:38445 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354Ab3IERYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:24:53 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so1056806eaj.20
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:24:52 -0700 (PDT)
In-Reply-To: <1378356196.1787.74.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 12:43 AM, Joe Perches <joe@perches.com> wrote:
> (Adding Yuchung Cheng and Neal Cardwell as the
>  author and acker of the patch)
>
> On Thu, 2013-09-05 at 00:20 -0400, Dave Jones wrote:
>> What's the intent here ?
>>
>> This ?
>
> I think the first is most likely.

Yes, exactly. The first version makes more sense. We only need to
check thin_dupack and potentially disable early retransmit if the
setsockopt successfully changes thin_dupack.

neal


>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index b2f6c74..95544e4 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -2454,10 +2454,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>>       case TCP_THIN_DUPACK:
>>               if (val < 0 || val > 1)
>>                       err = -EINVAL;
>> -             else
>> +             else {
>>                       tp->thin_dupack = val;
>>                       if (tp->thin_dupack)
>>                               tcp_disable_early_retrans(tp);
>> +             }
>>               break;
>>
>>       case TCP_REPAIR:
>>
>> Or this ...
>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index b2f6c74..187c5a4 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -2456,8 +2456,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>>                       err = -EINVAL;
>>               else
>>                       tp->thin_dupack = val;
>> -                     if (tp->thin_dupack)
>> -                             tcp_disable_early_retrans(tp);
>> +
>> +             if (tp->thin_dupack)
>> +                     tcp_disable_early_retrans(tp);
>>               break;
>>
>>       case TCP_REPAIR:
>>
>>
>> I'll submit the right patch in the right form once I know what was intended.
>>
>> The former seems more 'correct' to me, but I'm unsure if that could break something.
>>
>>       Dave
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
>
