From: Ji <lijimlee@gmail.com>
Subject: Re: Question about TLP patch
Date: Sun, 4 May 2014 14:41:05 -0700
Message-ID: <CAJdgut8FJZDfp5EZ-jESPGWDd5dmEhKgPunLHORh3xV=AuFS3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Weiping Pan <panweiping3@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:63357 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaEDVlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 17:41:07 -0400
Received: by mail-vc0-f178.google.com with SMTP id hu19so7935190vcb.9
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 14:41:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Weiping.

As you found, I finally figured it out that it could be for "Recovery
of any N-degree tail loss". However, I was actually testing with ER
only (i,e, with TLP off, sysctl tcp_early_retrans =1) and loss pattern
was "ALSL" ("S" means sacked, not 3-degree tail loss "ALLL"), and
noticed ER behaves different from RFC5827.

I understand that it may bring unnecessarily complexity in code if
strictly following RFC5827 (early retransmit must be used only when
"oseg - 1" segments have been SACKed) when TLP disabled. However,
IMHO, a comment might be good for readers.

Thanks,
Ji Li


On Sat, May 3, 2014 at 8:05 PM, Weiping Pan <panweiping3@gmail.com> wrote:
> On 04/24/2014 07:09 AM, Ji wrote:
>>
>> When reading the patch of Tail Loss Probe:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6ba8a3b19e764b6a65e4030ab0999be50c291e6c
>> , I noticed this change:
>>
>> @@ -2321,7 +2322,7 @@ static bool tcp_time_to_recover(struct sock *sk, int
>> flag)
>> * interval if appropriate.
>> */
>> if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
>> - (tp->packets_out == (tp->sacked_out + 1) && tp->packets_out < 4) &&
>> + (tp->packets_out >= (tp->sacked_out + 1) && tp->packets_out < 4) &&
>> !tcp_may_send_now(sk))
>> return !tcp_pause_early_retransmit(sk, flag);
>>
>> I think the original code is because of RFC5827 Early Retransmit for TCP,
>> 3.2
>> "... When conditions (3.a) and (3.b) hold and a TCP connection does
>>
>>     support SACK or SCTP is in use, Early Retransmit MUST be used only
>>
>>     when "oseg - 1" segments have been SACKed...."
>>
>> With that change, it seems that the condition is relaxed. I wonder
>> why it is so. Could you cast some lights on it?
>
> Please refer to
> http://tools.ietf.org/html/draft-dukkipati-tcpm-tcp-loss-probe-01
> 4.2. Recovery of any N-degree tail loss
>
> thanks
> Weiping Pan
>>
>>
>> Thanks,
>> Ji Li
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
