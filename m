From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Sat, 23 May 2015 00:46:43 +0200
Message-ID: <555FB1D3.6030507@iogearbox.net>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41279 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161117AbbEVWqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:46:48 -0400
In-Reply-To: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2015 12:42 AM, Alexei Starovoitov wrote:
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

LGTM, thanks!

Tested-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
