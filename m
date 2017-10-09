From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix a BUG in rt6_get_pcpu_route()
Date: Sun, 08 Oct 2017 21:09:25 -0700 (PDT)
Message-ID: <20171008.210925.827551076364200168.davem@davemloft.net>
References: <20171008151839.24519-1-idosch@mellanox.com>
        <1507478633.14419.30.camel@edumazet-glaptop3.roam.corp.google.com>
        <1507522038.31614.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, netdev@vger.kernel.org, weiwan@google.com,
        mlxsw@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdJIEJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:09:26 -0400
In-Reply-To: <1507522038.31614.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 08 Oct 2017 21:07:18 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Ido reported following splat and provided a patch.
> 
> [  122.221814] BUG: using smp_processor_id() in preemptible [00000000] code: sshd/2672
> [  122.221845] caller is debug_smp_processor_id+0x17/0x20
> [  122.221866] CPU: 0 PID: 2672 Comm: sshd Not tainted 4.14.0-rc3-idosch-next-custom #639
> [  122.221880] Hardware name: Mellanox Technologies Ltd. MSN2100-CB2FO/SA001017, BIOS 5.6.5 06/07/2016
> [  122.221893] Call Trace:
> [  122.221919]  dump_stack+0xb1/0x10c
> [  122.221946]  ? _atomic_dec_and_lock+0x124/0x124
> [  122.221974]  ? ___ratelimit+0xfe/0x240
> [  122.222020]  check_preemption_disabled+0x173/0x1b0
> [  122.222060]  debug_smp_processor_id+0x17/0x20
> [  122.222083]  ip6_pol_route+0x1482/0x24a0
> ...
> 
> I believe we can simplify this code path a bit, since we no longer
> hold a read_lock and need to release it to avoid a dead lock.
> 
> By disabling BH, we make sure we'll prevent code re-entry and
> rt6_get_pcpu_route()/rt6_make_pcpu_route() run on the same cpu. 
> 
> Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Ido Schimmel <idosch@mellanox.com>

Applied, thanks Eric.
