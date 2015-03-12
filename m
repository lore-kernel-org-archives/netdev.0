From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] cls_bpf: do eBPF invocation under non-bh RCU
 lock variant for maps
Date: Thu, 12 Mar 2015 14:26:07 -0700
Message-ID: <5502046F.4030409@plumgrid.com>
References: <91a3d08794f55f1f7a86a45f5d00ee72c8106061.1426185074.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:41237 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbCLV0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:26:03 -0400
Received: by pdjy10 with SMTP id y10so23110337pdj.8
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:26:02 -0700 (PDT)
In-Reply-To: <91a3d08794f55f1f7a86a45f5d00ee72c8106061.1426185074.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/15 12:03 PM, Daniel Borkmann wrote:
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

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

thanks!
