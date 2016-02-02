From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: addrconf: Fix recursive spin lock call
Date: Tue, 2 Feb 2016 15:02:24 +0100
Message-ID: <56B0B6F0.9050608@stressinduktion.org>
References: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>
To: subashab@codeaurora.org, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59830 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754494AbcBBOC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:02:26 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id C6C27214AE
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 09:02:25 -0500 (EST)
In-Reply-To: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2016 03:11, subashab@codeaurora.org wrote:
> A rcu stall with the following backtrace was seen on a system with
> forwarding, optimistic_dad and use_optimistic set. To reproduce,
> set these flags and allow ipv6 autoconf.
>
> This occurs because the device write_lock is acquired while already
> holding the read_lock. Back trace below -
>
> INFO: rcu_preempt self-detected stall on CPU { 1}  (t=2100 jiffies
>   g=3992 c=3991 q=4471)
> <6> Task dump for CPU 1:
> <2> kworker/1:0     R  running task    12168    15   2 0x00000002
> <2> Workqueue: ipv6_addrconf addrconf_dad_work
> <6> Call trace:
> <2> [<ffffffc000084da8>] el1_irq+0x68/0xdc
> <2> [<ffffffc000cc4e0c>] _raw_write_lock_bh+0x20/0x30
> <2> [<ffffffc000bc5dd8>] __ipv6_dev_ac_inc+0x64/0x1b4
> <2> [<ffffffc000bcbd2c>] addrconf_join_anycast+0x9c/0xc4
> <2> [<ffffffc000bcf9f0>] __ipv6_ifa_notify+0x160/0x29c
> <2> [<ffffffc000bcfb7c>] ipv6_ifa_notify+0x50/0x70
> <2> [<ffffffc000bd035c>] addrconf_dad_work+0x314/0x334
> <2> [<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
> <2> [<ffffffc0000b7324>] worker_thread+0x2f8/0x418
> <2> [<ffffffc0000bb40c>] kthread+0xe0/0xec
>
> v2: do addrconf_dad_kick inside read lock and then acquire write
> lock for ipv6_ifa_notify as suggested by Eric
>
> Fixes: 7fd2561e4ebdd ("net: ipv6: Add a sysctl to make optimistic
> addresses useful candidates")
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Erik Kline <ek@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Definitely a stable candidate, thanks!
