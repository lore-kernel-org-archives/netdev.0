From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cls_bpf: do eBPF invocation under non-bh RCU
 lock variant for maps
Date: Thu, 12 Mar 2015 18:34:14 -0400 (EDT)
Message-ID: <20150312.183414.1945413886342985069.davem@davemloft.net>
References: <91a3d08794f55f1f7a86a45f5d00ee72c8106061.1426185074.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbbCLWeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:34:15 -0400
In-Reply-To: <91a3d08794f55f1f7a86a45f5d00ee72c8106061.1426185074.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 12 Mar 2015 20:03:12 +0100

> Currently, it is possible in cls_bpf to access eBPF maps only under
> rcu_read_lock_bh() variants: while on ingress side, that is, handle_ing(),
> the classifier would be called from __netif_receive_skb_core() under
> rcu_read_lock(); on egress side, however, it's rcu_read_lock_bh() via
> __dev_queue_xmit().
> 
> This rcu/rcu_bh mix doesn't work together with eBPF maps as they require
> soley to be called under rcu_read_lock(). eBPF maps could also be shared
> among various other eBPF programs (possibly even with other eBPF program
> types, f.e. tracing) and user space processes, so any context is assumed.
> 
> Therefore, a possible fix for cls_bpf is to wrap/nest eBPF program
> invocation under non-bh RCU lock variant.
> 
> Fixes: e2e9b6541dd4 ("cls_bpf: add initial eBPF support for programmable classifiers")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
