From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 14:52:28 -0800
Message-ID: <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
 <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
 <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
 <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com> <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35094 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdB1XST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 18:18:19 -0500
Received: by mail-ua0-f171.google.com with SMTP id q7so174094uaf.2
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 15:18:18 -0800 (PST)
In-Reply-To: <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 2:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-02-28 at 14:25 -0800, Andy Lutomirski wrote:
>> On Tue, Feb 28, 2017 at 1:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2017-02-28 at 13:09 -0800, Andy Lutomirski wrote:
>> >
>> >> Does this mean that a user program that does a zerocopy send can cause
>> >> a retransmitted segment to contain different data than the original
>> >> segment?  If so, is that okay?
>> >
>> > Same remark applies to sendfile() already
>>
>> True.
>>
>> >, or other zero copy modes
>> > (vmsplice() + splice() )
>>
>> I hate vmsplice().  I thought I remembered it being essentially
>> disabled at some point due to security problems.
>
> Right, zero copy is hard ;)
>
> vmsplice() is not disabled in current kernels, unless I missed
> something.
>

I think you're right.  That being said, from the man page:

The user pages are a gift to the kernel.  The application  may  not
modify this memory ever, otherwise the page cache and on-disk data may
differ.

This is just not okay IMO.
