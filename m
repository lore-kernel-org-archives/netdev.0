From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Tue, 22 Aug 2017 10:44:23 -0700
Message-ID: <1503423863.2499.39.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
         <1503406926.2499.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <bf580154-aea9-4143-5d9c-df3764b5e745@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Akshat Kakkar <akshat.1984@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34244 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752120AbdHVRoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:44:25 -0400
Received: by mail-pg0-f65.google.com with SMTP id i12so12613405pgr.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:44:25 -0700 (PDT)
In-Reply-To: <bf580154-aea9-4143-5d9c-df3764b5e745@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-22 at 09:43 -0700, David Ahern wrote:
> On 8/22/17 6:02 AM, Eric Dumazet wrote:
> >>
> >> net.core.netdev_max_backlog=10000
> > This is an insane backlog.
> > 
> 
> https://www.kernel.org/doc/Documentation/networking/scaling.txt
> 
> "== Suggested Configuration
> 
> Flow limit is useful on systems with many concurrent connections,
> where a single connection taking up 50% of a CPU indicates a problem.
> In such environments, enable the feature on all CPUs that handle
> network rx interrupts (as set in /proc/irq/N/smp_affinity).
> 
> The feature depends on the input packet queue length to exceed
> the flow limit threshold (50%) + the flow history length (256).
> Setting net.core.netdev_max_backlog to either 1000 or 10000
> performed well in experiments."

10000 is adding tail latencies.

At Google we run all the fleet with backlog of 1000

And yes, it took time to get rid of the backlog of 10000 that was setup
years ago, because of old constraints and some fears.

Willem wrote this doc in 2013, before we finally went back to 1000.

We should update this doc.
