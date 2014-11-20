From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] filter: add bpf_optimize_div()
Date: Thu, 20 Nov 2014 22:32:25 +0100
Message-ID: <546E5DE9.3050602@redhat.com>
References: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788AbaKTVci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 16:32:38 -0500
In-Reply-To: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2014 08:42 PM, Denis Kirjanov wrote:
> optimize_div() found in  mips bpf jit is really usefull
> for other arches. So let's put it in filter.h
>
> CC: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

NAK

1) There's no user of this function (you name MIPS JIT, but
    don't remove it from there) ...

2) It's not really specific or tied to the BPF API in particular,
    so doesn't really belong here, rather some more generic kernel
    header, iff anything.

> ---
>   include/linux/filter.h | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index ca95abd..b385637 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -414,6 +414,17 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>   		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
>   			       16, 1, image, proglen, false);
>   }
> +
> +static inline int bpf_optimize_div(u32 *k)
> +{
> +	/* power of 2 divides can be implemented with right shift */
> +	if (!(*k & (*k-1))) {
> +		*k = ilog2(*k);
> +		return 1;
> +	}
> +
> +	return 0;
> +}
>   #else
>   static inline void bpf_jit_compile(struct bpf_prog *fp)
>   {
>
