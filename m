From: Zhiyun Qian <zhiyunq@umich.edu>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 14:49:03 -0500
Message-ID: <CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	<1356114663.21834.7697.camel@edumazet-glaptop>
	<CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	<1356118052.21834.7793.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:55658 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab2LUTtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:49:05 -0500
Received: by mail-wi0-f175.google.com with SMTP id hm11so5382063wib.14
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 11:49:03 -0800 (PST)
In-Reply-To: <1356118052.21834.7793.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2012 at 2:27 PM, Eric Dumazet <erdnetdev@gmail.com> wrote:
> On Fri, 2012-12-21 at 14:10 -0500, Zhiyun Qian wrote:
>> That's good to know. However, implementing RFC 5961 alone is not
>> sufficient. Like I said, since DelayedAckLost counter is incremented
>> purely upon looking at the sequence number, regardless of the ACK
>> number. An attacker thus can still infer the sequence number based on
>> DelayedAckLost counter without knowing the right ACK number.
>>
>
>
>
>> The next question is how can the attacker eventually know the right
>> ACK number in order to inject real data. It turns out that this is not
>> hard either. First, based on the current Linux TCP stack, it accepts
>> incoming packets without ACK flag.
>
> I dont really think so.
>
> We must discard frame is th->ack is not set. (Step 5, line 6142)
>

If I am not mistaken, line 6142 in kernel v3.7.1 corresponds to
tcp_rcv_state_process(). According to the comments, "This function
implements the receiving procedure of RFC 793 for all states except
ESTABLISHED and TIME_WAIT." Are you referring to a different kernel
version?

>
>
>> Further, if ACK flag is not set,
>> ACK number will not be checked at all. See code in
>> net/ipv4/tcp_input.c, function tcp_rcv_established()
>>
>> 5547        if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
>> 5548                goto discard;
>>
>> Second, even if ACK number is always checked before accepting the
>> payload, it is still possible to infer the ACK number much like how
>> sequence number can be inferred. The details is described in Section
>> 3.4 of my paper, paragraph starting with "Client-side sequence number
>> inference".
>>
>> I'm looking at the latest kernel v3.7.1 right now. I believe the
>> problem do still exist in today's Linux.
>>
>
> It seems you know pretty well this code, I wonder why you dont send
> patches to fix the bugs...
>
> Its not like it has to be buggy forever.
>

I have never submitted any patch before...I would do it if no one else
wants to :)

>
>
