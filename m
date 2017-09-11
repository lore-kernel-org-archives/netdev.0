From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Mon, 11 Sep 2017 07:49:17 -0700
Message-ID: <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        edumazet@google.com, ycheng@google.com, hkchu@google.com,
        netdev@vger.kernel.org, weiyongjun1@huawei.com
To: liujian56@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33183 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdIKOtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 10:49:21 -0400
Received: by mail-pf0-f182.google.com with SMTP id y29so13526181pff.0
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 07:49:21 -0700 (PDT)
In-Reply-To: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-11 at 14:27 +0800, liujian56@huawei.com wrote:
> From: liujian <liujian56@huawei.com>
> 
> After the tcp socket go to ESTABLISHED stat, change IP address (server
> side),
> then the tcp socket will go tcp_probe_timer process.
> 
> [root@localhost net]# netstat -toe
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      Timer
> tcp        0   1104 9.81.254:personal-agent 9.84.201.213:23597      ESTABLISHED root       12819      probe (4.36/0/7)
> [root@localhost net]# cat /proc/net/tcp
>   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                                     
>    3: B1FE5109:15B3 D5C95409:5C2D 01 00000495:00000000 04:0000005E 00000000     0        7 12819 2 ffff95cdcf45a000 20 4 1 10 -1 
> 
> In my test case, tcp_write_queue_head(sk) and tcp_send_head(sk) is  same
> SKB.
> And ((s32)(tcp_time_stamp(tp) - start_ts) >
> jiffies_to_msecs(icsk->icsk_user_timeout))
>  always is false.

Interesting.

>  Here use keepalive_time_elapsed(tp) to do the compare as
> tcp_keepalive_timer do.


But zero window probe and TCP_USER_TIMEOUT can be used without
keepalives...


A packetdrill test would help, I will write one.

Thanks.
