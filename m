From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
Date: Tue, 21 May 2013 09:44:13 +0200
Message-ID: <519B25CD.5060801@redhat.com>
References: <20130521142537.00a9ccb7ca4aa81f553b61cf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Schichan <nschichan@freebox.fr>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130521142537.00a9ccb7ca4aa81f553b61cf@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 05/21/2013 06:25 AM, Stephen Rothwell wrote:
> Hi Andrew,
>
> Today's linux-next merge of the akpm tree got a conflict in
> arch/arm/net/bpf_jit_32.c between commit aafc787e41fd ("arm: bpf_jit: can
> call module_free() from any context") from the net-next tree and commit
> "ARM: net: bpf_jit: make code generation less dependent on struct
> sk_filter" from the akpm tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Also seccomp_jit_free() needs a change otherwise the kernel won't build
with CONFIG_SECCOMP_FILTER_JIT enabled since the work_struct is initialized
with the bpf_jit_free_worker() callback, which is no longer existent.

Do you want me to send you a patch?

Quite frankly, I don't like so much that {seccomp,bpf}_jit_compile() and
{seccomp,bpf}_jit_free() are almost idential functions and now both need
to be maintained with the same changes, but that's off-topic here.

Cheers,

Daniel
