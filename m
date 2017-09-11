From: David Miller <davem@davemloft.net>
Subject: Re: [V3 PATCH net] xdp: implement xdp_redirect_map for generic XDP
Date: Mon, 11 Sep 2017 14:33:40 -0700 (PDT)
Message-ID: <20170911.143340.2229370127207977653.davem@davemloft.net>
References: <20170908.205426.624386613610674398.davem@davemloft.net>
        <150502962259.28817.7472180087690436639.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        andy@greyhouse.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56402 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdIKVdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:33:41 -0400
In-Reply-To: <150502962259.28817.7472180087690436639.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Sun, 10 Sep 2017 09:47:02 +0200

> Using bpf_redirect_map is allowed for generic XDP programs, but the
> appropriate map lookup was never performed in xdp_do_generic_redirect().
> 
> Instead the map-index is directly used as the ifindex.  For the
> xdp_redirect_map sample in SKB-mode '-S', this resulted in trying
> sending on ifindex 0 which isn't valid, resulting in getting SKB
> packets dropped.  Thus, the reported performance numbers are wrong in
> commit 24251c264798 ("samples/bpf: add option for native and skb mode
> for redirect apps") for the 'xdp_redirect_map -S' case.
> 
> Before commit 109980b894e9 ("bpf: don't select potentially stale
> ri->map from buggy xdp progs") it could crash the kernel.  Like this
> commit also check that the map_owner owner is correct before
> dereferencing the map pointer.  But make sure that this API misusage
> can be caught by a tracepoint. Thus, allowing userspace via
> tracepoints to detect misbehaving bpf_progs.
> 
> Fixes: 6103aa96ec07 ("net: implement XDP_REDIRECT for xdp generic")
> Fixes: 24251c264798 ("samples/bpf: add option for native and skb mode for redirect apps")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
