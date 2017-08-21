From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Mon, 21 Aug 2017 10:17:07 -0400
Message-ID: <CADVnQyk5EDY8ZVJysjbwZ5Ws=yc7kuZS=jMxh57cAKgEdAva_Q@mail.gmail.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
 <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
 <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
 <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com> <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Laight <David.Laight@aculab.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:38907 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753264AbdHUORj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 10:17:39 -0400
Received: by mail-qt0-f172.google.com with SMTP id 57so5853528qtu.5
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 07:17:39 -0700 (PDT)
In-Reply-To: <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 5:56 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
>
> The issue is with tcp timestamp. When I am disabling it, things are
> working fine but when I enable the issue re-occurs. However, I am not
> seeing tcp timestamps on packet, even when it is enabled simply
> because my client doesn't support it.
>
> But the question is, if I my client doesnt support timestamp , why
> enabling timestamp on server side is creating an issue??

To help shed light on this, you could try collecting and dumping the
nstat counters when the system is in the mode where it is not
creating/accepting new connections, e.g.:

nstat > /dev/null && sleep 10 && nstat

The sleep interval would need to be long enough to cover a failing
client connect attempt. It would also be helpful to gather a tcpdump
trace over the interval, to see if the server is sending a RST,
SYN+ACK, or nothing.

neal
