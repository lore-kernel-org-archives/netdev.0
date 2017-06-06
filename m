From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: cgroup skb progs cannot access ld_abs/ind
Date: Tue, 06 Jun 2017 16:40:05 -0400 (EDT)
Message-ID: <20170606.164005.76474638904598005.davem@davemloft.net>
References: <1851c3df45588eb96803995a3ceff32819612386.1496766858.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengc@google.com, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39882 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdFFUkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:40:07 -0400
In-Reply-To: <1851c3df45588eb96803995a3ceff32819612386.1496766858.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  6 Jun 2017 18:38:04 +0200

> Commit fb9a307d11d6 ("bpf: Allow CGROUP_SKB eBPF program to
> access sk_buff") enabled programs of BPF_PROG_TYPE_CGROUP_SKB
> type to use ld_abs/ind instructions. However, at this point,
> we cannot use them, since offsets relative to SKF_LL_OFF will
> end up pointing skb_mac_header(skb) out of bounds since in the
> egress path it is not yet set at that point in time, but only
> after __dev_queue_xmit() did a general reset on the mac header.
> bpf_internal_load_pointer_neg_helper() will then end up reading
> data from a wrong offset.
> 
> BPF_PROG_TYPE_CGROUP_SKB programs can use bpf_skb_load_bytes()
> already to access packet data, which is also more flexible than
> the insns carried over from cBPF.
> 
> Fixes: fb9a307d11d6 ("bpf: Allow CGROUP_SKB eBPF program to access sk_buff")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Aha, I see, applied.

Thanks!
