From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Mon, 25 May 2015 00:19:32 -0400 (EDT)
Message-ID: <20150525.001932.849051101973512567.davem@davemloft.net>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbEYETh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:19:37 -0400
In-Reply-To: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 22 May 2015 15:42:55 -0700

> x86 has variable length encoding. x86 JIT compiler is trying
> to pick the shortest encoding for given bpf instruction.
> While doing so the jump targets are changing, so JIT is doing
> multiple passes over the program. Typical program needs 3 passes.
> Some very short programs converge with 2 passes. Large programs
> may need 4 or 5. But specially crafted bpf programs may hit the
> pass limit and if the program converges on the last iteration
> the JIT compiler will be producing an image full of 'int 3' insns.
> Fix this corner case by doing final iteration over bpf program.
> 
> Fixes: 0a14842f5a3c ("net: filter: Just In Time compiler for x86-64")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thanks.
