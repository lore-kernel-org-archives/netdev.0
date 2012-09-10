From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/ipv4/route.c:645 suspicious rcu_dereference_check() usage!
Date: Mon, 10 Sep 2012 11:46:51 +0200
Message-ID: <1347270411.1234.1360.camel@edumazet-glaptop>
References: <84c8a8$5m6f27@orsmga001.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chris@chris-wilson.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57712 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2IJJq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 05:46:56 -0400
In-Reply-To: <84c8a8$5m6f27@orsmga001.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 09:44 +0100, chris@chris-wilson.co.uk wrote:
> I've not seen this reported yet, so here's a warning that happens
> occasionally:
> 
> [192979.475833] 
> [192979.475840] ===============================
> [192979.475841] [ INFO: suspicious RCU usage. ]
> [192979.475844] 3.6.0-rc2+ #33 Not tainted
> [192979.475846] -------------------------------
> [192979.475848] net/ipv4/route.c:645 suspicious rcu_dereference_check() usage!
> [192979.475850] 
> [192979.475850] other info that might help us debug this:
> [192979.475850] 
> [192979.475853] 
> [192979.475853] rcu_scheduler_active = 1, debug_locks = 0
> [192979.475856] 2 locks held by firefox-bin/4634:
> [192979.475858]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff814261b4>] release_sock+0x34/0x1e0
> [192979.475870]  #1:  (fnhe_lock){+.-...}, at: [<ffffffff81461c94>] update_or_create_fnhe.isra.30+0x44/0x480
> [192979.475878] 
> [192979.475878] stack backtrace:
> [192979.475881] Pid: 4634, comm: firefox-bin Not tainted 3.6.0-rc2+ #33
> [192979.475883] Call Trace:
> [192979.475891]  [<ffffffff810903cd>] lockdep_rcu_suspicious+0xfd/0x130
> [192979.475895]  [<ffffffff81461e8e>] update_or_create_fnhe.isra.30+0x23e/0x480
> [192979.475899]  [<ffffffff814624ba>] __ip_rt_update_pmtu.isra.31+0x6a/0xb0
> [192979.475903]  [<ffffffff81465038>] ip_rt_update_pmtu+0x48/0xd0
> [192979.475907]  [<ffffffff814759b1>] inet_csk_update_pmtu+0x31/0x80
> [192979.475912]  [<ffffffff8148b663>] tcp_v4_mtu_reduced+0x33/0xd0
> [192979.475915]  [<ffffffff814888be>] tcp_release_cb+0x5e/0xb0
> [192979.475919]  [<ffffffff81426289>] release_sock+0x109/0x1e0
> [192979.475922]  [<ffffffff81479037>] tcp_sendmsg+0x527/0x1030
> [192979.475927]  [<ffffffff814a4d9d>] inet_sendmsg+0xed/0x240
> [192979.475931]  [<ffffffff814a4cb0>] ? inet_autobind+0x70/0x70
> [192979.475934]  [<ffffffff81424e8a>] ? sock_update_classid+0xaa/0x370
> [192979.475937]  [<ffffffff81424eb8>] ? sock_update_classid+0xd8/0x370
> [192979.475941]  [<ffffffff8141ee1b>] sock_sendmsg+0xab/0xe0
> [192979.475946]  [<ffffffff814222be>] sys_sendto+0x11e/0x160
> [192979.475951]  [<ffffffff8153e547>] ? sysret_check+0x1b/0x56
> [192979.475956]  [<ffffffff8125849e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [192979.475960]  [<ffffffff8153e522>] system_call_fastpath+0x16/0x1b
> 

Probably already fixed in commit c5ae7d41927d (ipv4: must use rcu
protection while calling fib_lookup)

3.6.0-rc2 is quite old for a dev kernel ;)

Thanks
