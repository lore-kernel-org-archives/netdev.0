From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Wed, 23 Aug 2017 09:35:59 -0400
Message-ID: <CADVnQy=33_0H8g7JaLtGaVpf0_hXrcgJpNiBeJEN_SvpGPT9CQ@mail.gmail.com>
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
 <CADVnQy=57_rc8A93zAcqr9hz1WtWniSoZdtx+-aTiZ6AyjZmQg@mail.gmail.com> <CAA5aLPgA+YzavA8tw6uqfR8d6r058OymJOE+jevVmDA2Ar21rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:34020 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753973AbdHWNgb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 09:36:31 -0400
Received: by mail-qt0-f174.google.com with SMTP id p10so758460qte.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 06:36:31 -0700 (PDT)
In-Reply-To: <CAA5aLPgA+YzavA8tw6uqfR8d6r058OymJOE+jevVmDA2Ar21rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 1:08 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
>
> On Tue, Aug 22, 2017 at 5:58 PM, Neal Cardwell <ncardwell@google.com> wrote:
> > On Tue, Aug 22, 2017 at 1:42 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> >> There are multiple hosts/clients. All are mainly windows based.
> >>
> >> Timestamp is not used as my clients mainly are windows based and in
> >> that it tcp timestamp is by defauly disabled.
> > ...
> >> net.ipv4.tcp_tw_reuse=1
> >> net.ipv4.tcp_tw_recycle=1
> >
> > I suspect the problem is there. The net.ipv4.tcp_tw_recycle setting
> > should be 0. Running with the value 1 is known to cause buggy behavior
> > related to TCP timestamps, and that feature has been removed in kernel
> > v4.12.
> >
> > Can you please re-run your tests with net.ipv4.tcp_tw_recycle=0 or a
> > newer kernel?
> >
> > neal
>
> Thanks for your reply.
>
> I understand that.
>
> But my point is, though tcp timestamp is enabled on the server, but as
> client is not using it ... so how come this _bug_ (if any) is
> triggered in first place.

You mention "clients mainly are windows based". if they are only
"mainly" Windows-based, and some are of other OSes that do use TCP
timestamps, and the remote address is the same for TCP-timestamp-using
and non-TCP-timestamp-using clients, then running with timestamps
enabled on the server could tickle the bugs in pre-4.12 kernels that
save info from TCP-timestamp-using connections and erroneously try to
use that info to validate non-TCP-timestamp-using connections.

But the main point is that the configuration you cited
(net.ipv4.tcp_tw_recycle=1) is an unsupported configuration with known
bugs. The best resolution would be to just run with
net.ipv4.tcp_tw_recycle=0. It's not worth digging any further unless
you run with net.ipv4.tcp_tw_recycle=0 or a kernel that is v4.12 or
later and still have problems.

Hope that helps,
neal
