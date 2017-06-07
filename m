From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: Question about tcp_filter() in tcp_v6_do_rcv()
Date: Wed, 7 Jun 2017 15:35:49 -0700
Message-ID: <c49c55de-5356-0804-9baf-f0ed12829055@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36698 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdFGWfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 18:35:51 -0400
Received: by mail-pg0-f67.google.com with SMTP id v18so2590344pgb.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 15:35:51 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody,

I am testing eBPF programs on ipv6 and I just find out the tcp_filter() 
function (previously named sk_filter()) is called both in tcp_v6_rcv() 
and tcp_v6_do_rcv(). In contrast, it is only called by tcp_v4_rcv() in 
ipv4 layer. I guess this implementation is used to capture some corner 
cases in ipv6 ingress route but I cannot find why. Could I know why we 
need this in two similar places in ipv6 transportation layer?

I have tried to dig into the commit history and the related code path 
but I did not see any obvious reason for doing so. And my problem with 
it is when a eBPF program is attached to a socket or a cgroup in ingress 
side, the filter program will be applied on some packets twice. And it 
affect the accuracy when using eBPF program for traffic accounting.

Thanks!

Chenbo Feng
