From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/9] bpf: array map: use pre-defined nop map function
Date: Mon, 11 Jan 2016 11:08:39 -0800
Message-ID: <20160111190839.GB26495@ast-mbp.thefacebook.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
 <1452527821-12276-3-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452527821-12276-3-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 11:56:54PM +0800, Ming Lei wrote:
> So that we can remove the per-map nop map fucntions.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> ---
>  kernel/bpf/arraymap.c | 19 +++++--------------
>  1 file changed, 5 insertions(+), 14 deletions(-)
> 
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index b0799bc..9ad9031 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -17,6 +17,8 @@
>  #include <linux/filter.h>
>  #include <linux/perf_event.h>
>  
> +#include "bpf_map.h"
> +
>  /* Called from syscall */
>  static struct bpf_map *array_map_alloc(union bpf_attr *attr)
>  {
> @@ -115,12 +117,6 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
>  	return 0;
>  }
>  
> -/* Called from syscall or from eBPF program */
> -static int array_map_delete_elem(struct bpf_map *map, void *key)
> -{
> -	return -EINVAL;
> -}
> -
>  /* Called when map->refcnt goes to zero, either from workqueue or from syscall */
>  static void array_map_free(struct bpf_map *map)
>  {
> @@ -142,7 +138,7 @@ static const struct bpf_map_ops array_ops = {
>  	.map_get_next_key = array_map_get_next_key,
>  	.map_lookup_elem = array_map_lookup_elem,
>  	.map_update_elem = array_map_update_elem,
> -	.map_delete_elem = array_map_delete_elem,
> +	.map_delete_elem = map_delete_elem_nop,

I think moving these two callbacks into separate file only
reduces readbility. It doesn't look like that we save any .text this way.
