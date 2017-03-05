From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] tcp: fix various issues for sockets morphing to
 listen state
Date: Sun, 5 Mar 2017 08:58:42 -0800
Message-ID: <CANn89iKaXGJnLAKubNG4h8wPECnoMttLDyWmRHgnGD+Unhew-Q@mail.gmail.com>
References: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
 <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
 <1488574561.9415.336.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488578901.9415.353.camel@edumazet-glaptop3.roam.corp.google.com> <CACT4Y+Z464Ex3UXm-v2OHXd1TCPke_WA_FEiVPAaBOMpFf+b+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36908 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCEQ6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 11:58:44 -0500
Received: by mail-it0-f53.google.com with SMTP id 203so37935320ith.0
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 08:58:43 -0800 (PST)
In-Reply-To: <CACT4Y+Z464Ex3UXm-v2OHXd1TCPke_WA_FEiVPAaBOMpFf+b+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 5, 2017 at 4:00 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Mar 3, 2017 at 11:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Dmitry Vyukov reported a divide by 0 triggered by syzkaller, exploiting
>> tcp_disconnect() path that was never really considered and/or used
>> before syzkaller ;)
>>
>> I was not able to reproduce the bug, but it seems issues here are the
>> three possible actions that assumed they would never trigger on a
>> listener.
>>
>> 1) tcp_write_timer_handler
>> 2) tcp_delack_timer_handler
>> 3) MTU reduction
>>
>> Only IPv6 MTU reduction was properly testing TCP_CLOSE and TCP_LISTEN
>>  states from tcp_v6_mtu_reduced()
>
> I've run the test as "while ./a.out; do true; done". I've also noticed
> that it either reproduces very quickly or does not happen at all. So I
> rebooted machine, run the program in loop and then repeated if it does
> not happen within seconds.

Yes, I was also doing this.

What I noticed is that your program did not use SO_REUSEADDR, meaning
the second (and later) bind() syscall would fail.

Maybe some sysctl difference between your host and mine....

>
> Retested with your patch, seems to not crash anymore.
>
Thanks for testing !
