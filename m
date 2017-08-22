From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Tue, 22 Aug 2017 08:28:14 -0400
Message-ID: <CADVnQy=57_rc8A93zAcqr9hz1WtWniSoZdtx+-aTiZ6AyjZmQg@mail.gmail.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
 <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
 <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
 <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
 <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
 <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
 <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com> <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34266 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932427AbdHVM2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 08:28:46 -0400
Received: by mail-qk0-f178.google.com with SMTP id u139so96033578qka.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 05:28:45 -0700 (PDT)
In-Reply-To: <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 1:42 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> There are multiple hosts/clients. All are mainly windows based.
>
> Timestamp is not used as my clients mainly are windows based and in
> that it tcp timestamp is by defauly disabled.
...
> net.ipv4.tcp_tw_reuse=1
> net.ipv4.tcp_tw_recycle=1

I suspect the problem is there. The net.ipv4.tcp_tw_recycle setting
should be 0. Running with the value 1 is known to cause buggy behavior
related to TCP timestamps, and that feature has been removed in kernel
v4.12.

Can you please re-run your tests with net.ipv4.tcp_tw_recycle=0 or a
newer kernel?

neal
