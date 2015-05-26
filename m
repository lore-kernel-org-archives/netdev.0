From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Tue, 26 May 2015 13:40:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:53807 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439AbbEZNlz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 09:41:55 -0400
In-Reply-To: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
> Sent: 22 May 2015 23:43
> x86 has variable length encoding. x86 JIT compiler is trying
> to pick the shortest encoding for given bpf instruction.
> While doing so the jump targets are changing, so JIT is doing
> multiple passes over the program. Typical program needs 3 passes.
> Some very short programs converge with 2 passes. Large programs
> may need 4 or 5. But specially crafted bpf programs may hit the
> pass limit and if the program converges on the last iteration
> the JIT compiler will be producing an image full of 'int 3' insns.
> Fix this corner case by doing final iteration over bpf program.

If the JIT compiler is only changing the encoding of the constants
in the x86 instructions (rather than changing the instructions themselves)
then there is likely to me an unmeasurable change in the execution time.
For instance I don't remember there being a difference in execution time
between long and short branches - the only difference is the amount of
cache they use.

	David
