From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: move load_pointer() into filter.h
Date: Thu, 03 Jul 2014 10:10:24 +0200
Message-ID: <53B50FF0.7080901@redhat.com>
References: <1404373932-10929-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404373932-10929-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zi,

On 07/03/2014 09:52 AM, Zi Shen Lim wrote:
> load_pointer() is already a static inline function.
> Let's move it into filter.h so BPF JIT implementations can reuse this
> function.
>
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> ---
> This patch is based on discussion with Alexei in the context of
> reusing load_pointer for upcoming arm64 BPF JIT compiler. [1]
>
> Compile tested on x86_64 and arm64.
>
> [1] https://lkml.org/lkml/2014/7/3/14
>
>   include/linux/filter.h | 13 +++++++++++++
>   net/core/filter.c      |  9 ---------
>   2 files changed, 13 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a7e3c48..2288e31 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -6,6 +6,7 @@
>
>   #include <linux/atomic.h>
>   #include <linux/compat.h>
> +#include <linux/skbuff.h>
>   #include <linux/workqueue.h>
>   #include <uapi/linux/filter.h>
>
> @@ -406,6 +407,18 @@ static inline u16 bpf_anc_helper(const struct sock_filter *ftest)
>   	}
>   }
>
> +void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb,
> +					   int k, unsigned int size);
> +
> +static inline void *load_pointer(const struct sk_buff *skb, int k,
> +				 unsigned int size, void *buffer)
> +{

Fine by me, but since you're exporting this into a header,
please give this a more specific name, such as bpf_load_pointer(),
for example.

Thanks,

Daniel
