From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net.ipv4.tcp_max_syn_backlog implementation
Date: Tue, 29 Aug 2017 09:17:10 -0700
Message-ID: <1504023430.11498.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
         <1503980243.11498.69.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAMB9WxJ_QHJr1pHKFO0YcYdQhHBL2Ch7ugccmf9gztALiY5f-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harsha Chenji <cjkernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37739 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbdH2QRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:17:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id a2so2621603pfj.4
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 09:17:11 -0700 (PDT)
In-Reply-To: <CAMB9WxJ_QHJr1pHKFO0YcYdQhHBL2Ch7ugccmf9gztALiY5f-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 11:05 -0400, Harsha Chenji wrote:
> According to the man:
> 
> The behavior of the backlog argument on TCP sockets changed with Linux
> 2.2. Now it specifies the queue length for *completely established
> sockets waiting to be accepted*, instead of the number of incomplete
> connection requests. The maximum length of the queue for incomplete
> sockets can be set using /proc/sys/net/ipv4/tcp_max_syn_backlog. When
> syncookies are enabled there is no logical maximum length and this
> setting is ignored. See tcp(7) for more information.
> 
> 


The sysctl was simply there to make sure that someone would not :

listen(fd, 0x40000000);

It served to cap the 2nd argument of listen() to something that the
admin considered as acceptable.

This was particularly important few years back when handling of SYN_RECV
sockets involved O(N) behavior for SYNACK retransmits.

Nowadays, a backlog of 10,000,000 is okay, if you have ram to spend on
it.

> On Tue, Aug 29, 2017 at 12:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2017-08-28 at 23:47 -0400, Harsha Chenji wrote:
> >> So I have ubuntu 12.04 x32 in a VM with syncookies turned off. I tried
> >> to do a syn flood (with netwox) on 3 different processes. Each of them
> >> returns a different value with netstat -na | grep -c RECV :
> >>
> >> nc -l 5555 returns 16 (netcat-traditional)
> >> apache2 port 80 returns 256
> >> vsftpd on 21 returns 64.
> >> net.ipv4.tcp_max_syn_backlog is 512.
> >>
> >> Why do these different processes on different ports have different
> >> queue lengths for incomplete connections? Where exactly in the kernel
> >> is this decided?
> >
> > See 2nd argument in listen() system call, ie backlog
> >
> > man listen
> >
> > Without a synflood, just look at "ss -t state listening"
> >
> > The backlog is the 2nd column (Send)
> >
> >
> >
