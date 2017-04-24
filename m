From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add rcu locking when changing early demux
Date: Mon, 24 Apr 2017 14:08:38 -0400 (EDT)
Message-ID: <20170424.140838.1224449140831206697.davem@davemloft.net>
References: <1492878796-31328-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, subashab@codeaurora.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975257AbdDXSIk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:08:40 -0400
In-Reply-To: <1492878796-31328-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 22 Apr 2017 09:33:16 -0700

> systemd-sysctl is triggering a suspicious RCU usage message when
> net.ipv4.tcp_early_demux or net.ipv4.udp_early_demux is changed via
> a sysctl config file:
> 
> [   33.896184] ===============================
> [   33.899558] [ ERR: suspicious RCU usage.  ]
> [   33.900624] 4.11.0-rc7+ #104 Not tainted
> [   33.901698] -------------------------------
> [   33.903059] /home/dsa/kernel-2.git/net/ipv4/sysctl_net_ipv4.c:305 suspicious rcu_dereference_check() usage!
> [   33.905724]
> other info that might help us debug this:
> 
> [   33.907656]
> rcu_scheduler_active = 2, debug_locks = 0
> [   33.909288] 1 lock held by systemd-sysctl/143:
> [   33.910373]  #0:  (sb_writers#5){.+.+.+}, at: [<ffffffff8123a370>] file_start_write+0x45/0x48
> [   33.912407]
> stack backtrace:
> [   33.914018] CPU: 0 PID: 143 Comm: systemd-sysctl Not tainted 4.11.0-rc7+ #104
> [   33.915631] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [   33.917870] Call Trace:
> [   33.918431]  dump_stack+0x81/0xb6
> [   33.919241]  lockdep_rcu_suspicious+0x10f/0x118
> [   33.920263]  proc_configure_early_demux+0x65/0x10a
> [   33.921391]  proc_udp_early_demux+0x3a/0x41
> 
> add rcu locking to proc_configure_early_demux.
> 
> Fixes: dddb64bcb3461 ("net: Add sysctl to toggle early demux for tcp and udp")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
