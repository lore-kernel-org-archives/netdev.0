From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Mon, 20 May 2013 06:52:12 -0700
Message-ID: <1369057932.3301.171.camel@edumazet-glaptop>
References: <1368844623.3301.142.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B723E@saturn3.aculab.com>
	 <5199F1E3.1020109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5199F1E3.1020109@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 11:50 +0200, Daniel Borkmann wrote:

> Here seems also to be another approach ...
> 
>    http://grsecurity.net/~spender/jit_prot.diff
> 
> via: http://www.reddit.com/r/netsec/comments/13dzhx/linux_kernel_jit_spray_for_smep_kernexec_bypass/


Well, there are many approaches, and I have another one as well provided
by H. Peter Anvin.

Idea was to allow the code being relocated outside of the 2GB space that
we use for kernel code (including module_alloc())

So every call helper, coded in "e8 xx xx xx xx" was replaced by

"48 c7 c0 yy yy yy yy   mov $foo,%rax"
"ff d0          call *%rax"

The RO protection + random holes idea was a solution with no performance
impact.

Another idea is to limit BPF JIT to root users. I do not think BPF JIT
is mandatory at all, as tcpdump is already restricted.
