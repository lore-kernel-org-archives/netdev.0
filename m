From: Harsha Chenji <cjkernel@gmail.com>
Subject: Re: net.ipv4.tcp_max_syn_backlog implementation
Date: Tue, 29 Aug 2017 11:05:49 -0400
Message-ID: <CAMB9WxJ_QHJr1pHKFO0YcYdQhHBL2Ch7ugccmf9gztALiY5f-w@mail.gmail.com>
References: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
 <1503980243.11498.69.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32916 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbdH2PFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 11:05:50 -0400
Received: by mail-io0-f196.google.com with SMTP id s101so3973255ioe.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 08:05:50 -0700 (PDT)
In-Reply-To: <1503980243.11498.69.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the man:

The behavior of the backlog argument on TCP sockets changed with Linux
2.2. Now it specifies the queue length for *completely established
sockets waiting to be accepted*, instead of the number of incomplete
connection requests. The maximum length of the queue for incomplete
sockets can be set using /proc/sys/net/ipv4/tcp_max_syn_backlog. When
syncookies are enabled there is no logical maximum length and this
setting is ignored. See tcp(7) for more information.


On Tue, Aug 29, 2017 at 12:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-08-28 at 23:47 -0400, Harsha Chenji wrote:
>> So I have ubuntu 12.04 x32 in a VM with syncookies turned off. I tried
>> to do a syn flood (with netwox) on 3 different processes. Each of them
>> returns a different value with netstat -na | grep -c RECV :
>>
>> nc -l 5555 returns 16 (netcat-traditional)
>> apache2 port 80 returns 256
>> vsftpd on 21 returns 64.
>> net.ipv4.tcp_max_syn_backlog is 512.
>>
>> Why do these different processes on different ports have different
>> queue lengths for incomplete connections? Where exactly in the kernel
>> is this decided?
>
> See 2nd argument in listen() system call, ie backlog
>
> man listen
>
> Without a synflood, just look at "ss -t state listening"
>
> The backlog is the 2nd column (Send)
>
>
>
