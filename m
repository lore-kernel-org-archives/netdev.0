From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about tcp_filter() in tcp_v6_do_rcv()
Date: Wed, 07 Jun 2017 16:06:10 -0700
Message-ID: <1496876770.736.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <c49c55de-5356-0804-9baf-f0ed12829055@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36747 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753625AbdFGXGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:06:12 -0400
Received: by mail-pg0-f65.google.com with SMTP id v18so2643431pgb.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 16:06:12 -0700 (PDT)
In-Reply-To: <c49c55de-5356-0804-9baf-f0ed12829055@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-07 at 15:35 -0700, Chenbo Feng wrote:
> Hello everybody,
> 
> I am testing eBPF programs on ipv6 and I just find out the tcp_filter() 
> function (previously named sk_filter()) is called both in tcp_v6_rcv() 
> and tcp_v6_do_rcv(). In contrast, it is only called by tcp_v4_rcv() in 
> ipv4 layer. I guess this implementation is used to capture some corner 
> cases in ipv6 ingress route but I cannot find why. Could I know why we 
> need this in two similar places in ipv6 transportation layer?
> 
> I have tried to dig into the commit history and the related code path 
> but I did not see any obvious reason for doing so. And my problem with 
> it is when a eBPF program is attached to a socket or a cgroup in ingress 
> side, the filter program will be applied on some packets twice. And it 
> affect the accuracy when using eBPF program for traffic accounting.

It seems this was added in this commit

commit 5234b9f7d650fe64975695d835cb9413e1d75f46
Author: James Morris <jmorris@intercode.com.au>
Date:   Thu Feb 6 09:49:40 2003 -0800

    [LSM]: Networking socket SKB receive hook.


You can find the history tree in :

[remote "origin"]
	url = git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
	fetch = +refs/heads/*:refs/remotes/origin/*


The call from tcp_v6_do_rcv() should be removed I guess
