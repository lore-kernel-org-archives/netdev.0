From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf, filter: do not convert skb->protocol to
 host endianess during runtime
Date: Fri, 20 Mar 2015 15:24:48 -0400 (EDT)
Message-ID: <20150320.152448.1094343268366721552.davem@davemloft.net>
References: <daaebd74ce31bd9ef7509c7083ba03d67af008bd.1426789778.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbCTTZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 15:25:01 -0400
In-Reply-To: <daaebd74ce31bd9ef7509c7083ba03d67af008bd.1426789778.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 19 Mar 2015 19:38:27 +0100

> Commit c24973957975 ("bpf: allow BPF programs access 'protocol' and 'vlan_tci'
> fields") has added support for accessing protocol, vlan_present and vlan_tci
> into the skb offset map.
> 
> As referenced in the below discussion, accessing skb->protocol from an eBPF
> program should be converted without handling endianess.
> 
> The reason for this is that an eBPF program could simply do a check more
> naturally, by f.e. testing skb->protocol == htons(ETH_P_IP), where the LLVM
> compiler resolves htons() against a constant automatically during compilation
> time, as opposed to an otherwise needed run time conversion.
> 
> After all, the way of programming both from a user perspective differs quite
> a lot, i.e. bpf_asm ["ld proto"] versus a C subset/LLVM.
> 
> Reference: https://patchwork.ozlabs.org/patch/450819/
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
