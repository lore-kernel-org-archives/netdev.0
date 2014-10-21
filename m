From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] bpf: fix bug in eBPF verifier
Date: Tue, 21 Oct 2014 12:35:42 +0200
Message-ID: <1413887742.32553.18.camel@localhost>
References: <1413842097-4380-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413842097-4380-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mo, 2014-10-20 at 14:54 -0700, Alexei Starovoitov wrote:
> while comparing for verifier state equivalency the comparison
> was missing a check for uninitialized register.
> Make sure it does so and add a testcase.
> 
> Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> 
> while we were staring at the verifier code with Hannes during LPC
> something felt odd in this spot. Yes. It was a bug. Fix it.
> 
>  kernel/bpf/verifier.c       |    3 ++-
>  samples/bpf/test_verifier.c |   11 +++++++++++
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 801f5f3..9f81818 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1409,7 +1409,8 @@ static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
>  		if (memcmp(&old->regs[i], &cur->regs[i],
>  			   sizeof(old->regs[0])) != 0) {
>  			if (old->regs[i].type == NOT_INIT ||
> -			    old->regs[i].type == UNKNOWN_VALUE)
> +			    (old->regs[i].type == UNKNOWN_VALUE &&
> +			     cur->regs[i].type != NOT_INIT))
>  				continue;
>  			return false;
>  		}

That makes sense.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
