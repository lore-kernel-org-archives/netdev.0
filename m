From: Tom Herbert <tom@herbertland.com>
Subject: Re: TCP fast open using experimental TCP option?
Date: Tue, 25 Apr 2017 17:39:31 -0700
Message-ID: <CALx6S35e2_92sYUR88YO10m_OhseeTjTr-nGWvpairOAY0_APQ@mail.gmail.com>
References: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
 <1493165636.6453.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34718 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1433753AbdDZApo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 20:45:44 -0400
Received: by mail-qk0-f174.google.com with SMTP id y63so130414500qkd.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 17:45:44 -0700 (PDT)
In-Reply-To: <1493165636.6453.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 5:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-04-25 at 12:08 -0700, Tom Herbert wrote:
>> Looks like TCP fast open was using experimental TCP option at some. Is
>> this still needed? Technically this violates usage requirements of
>> experimental options. Can this be removed now since there is now an
>> assigned option number for TFO?
>>
>>                              case TCPOPT_EXP:
>>                                 /* Fast Open option shares code 254 using a
>>                                  * 16 bits magic number.
>>                                  */
>>                                 if (opsize >= TCPOLEN_EXP_FASTOPEN_BASE &&
>>                                     get_unaligned_be16(ptr) ==
>>                                     TCPOPT_FASTOPEN_MAGIC)
>>                                         tcp_parse_fastopen_option(opsize -
>>                                                 TCPOLEN_EXP_FASTOPEN_BASE,
>>                                                 ptr + 2, th->syn, foc, true);
>>                                 break;
>
> Hi Tom
>
> Client side was updated in linux-4.1 only two years ago.
>
> We lack counters telling how often the experimental option is used.
>
> RFC6994 ( 5.  Migration to Assigned Options ) guidelines are properly
> met.
>
> Not sure why we should hurry ?
>
An IETFer was complaining that Linux indiscriminately violates TCP
RFCs and gave the use of experimental options as example. Yuchung
pointed out that this use is actually conformant to the spec so we're
good (thanks Yuchung!).

Tom

>
