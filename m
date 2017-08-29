From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net.ipv4.tcp_max_syn_backlog implementation
Date: Mon, 28 Aug 2017 21:17:23 -0700
Message-ID: <1503980243.11498.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harsha Chenji <cjkernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34745 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdH2ERZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 00:17:25 -0400
Received: by mail-pg0-f52.google.com with SMTP id y15so7455451pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 21:17:25 -0700 (PDT)
In-Reply-To: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-28 at 23:47 -0400, Harsha Chenji wrote:
> So I have ubuntu 12.04 x32 in a VM with syncookies turned off. I tried
> to do a syn flood (with netwox) on 3 different processes. Each of them
> returns a different value with netstat -na | grep -c RECV :
> 
> nc -l 5555 returns 16 (netcat-traditional)
> apache2 port 80 returns 256
> vsftpd on 21 returns 64.
> net.ipv4.tcp_max_syn_backlog is 512.
> 
> Why do these different processes on different ports have different
> queue lengths for incomplete connections? Where exactly in the kernel
> is this decided?

See 2nd argument in listen() system call, ie backlog 

man listen

Without a synflood, just look at "ss -t state listening" 

The backlog is the 2nd column (Send)
