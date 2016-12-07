From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix loading of BPF_MAXINSNS sized
 programs
Date: Wed, 07 Dec 2016 13:18:04 -0500 (EST)
Message-ID: <20161207.131804.1728136405665915871.davem@davemloft.net>
References: <7aad2a49d7a717fd018b338bb9d7167bafd1fdb8.1481069166.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932621AbcLGSSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:18:06 -0500
In-Reply-To: <7aad2a49d7a717fd018b338bb9d7167bafd1fdb8.1481069166.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  7 Dec 2016 01:15:44 +0100

> General assumption is that single program can hold up to BPF_MAXINSNS,
> that is, 4096 number of instructions. It is the case with cBPF and
> that limit was carried over to eBPF. When recently testing digest, I
> noticed that it's actually not possible to feed 4096 instructions
> via bpf(2).
> 
> The check for > BPF_MAXINSNS was added back then to bpf_check() in
> cbd357008604 ("bpf: verifier (add ability to receive verification log)").
> However, 09756af46893 ("bpf: expand BPF syscall with program load/unload")
> added yet another check that comes before that into bpf_prog_load(),
> but this time bails out already in case of >= BPF_MAXINSNS.
> 
> Fix it up and perform the check early in bpf_prog_load(), so we can drop
> the second one in bpf_check(). It makes sense, because also a 0 insn
> program is useless and we don't want to waste any resources doing work
> up to bpf_check() point. The existing bpf(2) man page documents E2BIG
> as the official error for such cases, so just stick with it as well.
> 
> Fixes: 09756af46893 ("bpf: expand BPF syscall with program load/unload")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  ( net-next is just fine imho. )

Applied.
