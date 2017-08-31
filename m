From: Neal Cardwell <ncardwell@google.com>
Subject: Re: net/ipv4: divide error in __tcp_select_window
Date: Thu, 31 Aug 2017 07:11:28 -0400
Message-ID: <CADVnQynuyK5H1SDOnzDZPOnVn701JhrSQRCORVJ_6c=z_EooBw@mail.gmail.com>
References: <CADUsjNnba_AmnTdoY45Bh7HasqjmBja-W1+-+6eMt-d_dCs2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Netdev <netdev@vger.kernel.org>, syzkaller@googlegroups.com,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>
To: idaifish <idaifish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33648 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdHaLMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 07:12:00 -0400
Received: by mail-qk0-f174.google.com with SMTP id l65so1356934qkc.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 04:12:00 -0700 (PDT)
In-Reply-To: <CADUsjNnba_AmnTdoY45Bh7HasqjmBja-W1+-+6eMt-d_dCs2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 1:56 AM, idaifish <idaifish@gmail.com> wrote:
> Hi:
>    This bug seems still can be triggered by the attached PoC on latest
> Ubuntu1604 (4.4.0-94-generic)
>
> ============================================================================
> divide error: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 0 PID: 14933 Comm: syz-executor0 Not tainted 4.9.45 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff880076ab9900 task.stack: ffff880062ae8000
> RIP: 0010:[<ffffffff829c1df3>]  [<ffffffff829c1df3>]
> __tcp_select_window+0x2f3/0x6b0 net/ipv4/tcp_output.c:2499
...
>  [<ffffffff8297c36e>] tcp_cleanup_rbuf+0x43e/0x4f0 net/ipv4/tcp.c:1468
>  [<ffffffff829815df>] tcp_recvmsg+0xc2f/0x25d0 net/ipv4/tcp.c:1937

Thanks for the report. I believe this tcp_recvmsg  => tcp_cleanup_rbuf
 => __tcp_select_window divide-by-zero issue was fixed in May by Wei,
in:

 499350a5a6e7 tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0
 https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=499350a5a6e7

Looks like we should probably mark this as a -stable candidate, so
that it will eventually make it to 4.4.y, 4.9.y, 4.12.y users, etc. (I
don't see the commit in those stable branches.)

thanks,
neal
