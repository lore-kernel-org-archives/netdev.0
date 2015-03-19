From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf, filter: do not convert skb->protocol to
 host endianess during runtime
Date: Thu, 19 Mar 2015 11:50:57 -0700
Message-ID: <550B1A91.6030502@plumgrid.com>
References: <daaebd74ce31bd9ef7509c7083ba03d67af008bd.1426789778.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34014 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbbCSSuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:50:54 -0400
Received: by pacwe9 with SMTP id we9so83501139pac.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 11:50:53 -0700 (PDT)
In-Reply-To: <daaebd74ce31bd9ef7509c7083ba03d67af008bd.1426789778.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/19/15 11:38 AM, Daniel Borkmann wrote:
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
> ---
>   (Follow-up from our previous discussion)

sure. let's save few run-time cycles.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
