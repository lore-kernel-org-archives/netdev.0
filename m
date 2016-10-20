From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, test: fix ld_abs + vlan push/pop stress test
Date: Thu, 20 Oct 2016 14:39:27 -0400 (EDT)
Message-ID: <20161020.143927.77719878578230890.davem@davemloft.net>
References: <24f37bd819eceb02c56fc5a6fcd5b8450b1db36a.1476976082.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933227AbcJTSj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:39:28 -0400
In-Reply-To: <24f37bd819eceb02c56fc5a6fcd5b8450b1db36a.1476976082.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 20 Oct 2016 17:13:53 +0200

> After commit 636c2628086e ("net: skbuff: Remove errornous length
> validation in skb_vlan_pop()") mentioned test case stopped working,
> throwing a -12 (ENOMEM) return code. The issue however is not due to
> 636c2628086e, but rather due to a buggy test case that got uncovered
> from the change in behaviour in 636c2628086e.
> 
> The data_size of that test case for the skb was set to 1. In the
> bpf_fill_ld_abs_vlan_push_pop() handler bpf insns are generated that
> loop with: reading skb data, pushing 68 tags, reading skb data,
> popping 68 tags, reading skb data, etc, in order to force a skb
> expansion and thus trigger that JITs recache skb->data. Problem is
> that initial data_size is too small.
> 
> While before 636c2628086e, the test silently bailed out due to the
> skb->len < VLAN_ETH_HLEN check with returning 0, and now throwing an
> error from failing skb_ensure_writable(). Set at least minimum of
> ETH_HLEN as an initial length so that on first push of data, equivalent
> pop will succeed.
> 
> Fixes: 4d9c5c53ac99 ("test_bpf: add bpf_skb_vlan_push/pop() tests")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
