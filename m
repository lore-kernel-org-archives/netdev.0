From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv3 perf/core 3/7] tools lib bpf: Add flags to
 bpf_create_map()
Date: Fri, 9 Dec 2016 11:36:18 +0800
Message-ID: <b2c274c5-5e2c-749f-648e-7664a1daa6c2@huawei.com>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209024620.31660-4-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <acme@kernel.org>,
        <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209024620.31660-4-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/9 10:46, Joe Stringer wrote:
> The map_flags argument to bpf_create_map() was previously not exposed.
> By exposing it, users can access flags such as whether or not to
> preallocate the map.
>
> Signed-off-by: Joe Stringer <joe@ovn.org>

Please mention commit 6c90598174322b8888029e40dd84a4eb01f56afe in
commit message:

Commit 6c905981743 ("bpf: pre-allocate hash map elements") introduces
map_flags to bpf_attr for BPF_MAP_CREATE command. Expose this new
parameter in libbpf.

Acked-by: Wang Nan <wangnan0@huawei.com>

> ---
> v3: Split from "tools lib bpf: Sync with samples/bpf/libbpf".
> ---
>   tools/lib/bpf/bpf.c    | 3 ++-
>   tools/lib/bpf/bpf.h    | 2 +-
>   tools/lib/bpf/libbpf.c | 3 ++-
>   3 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
> index 89e8e8e5b60e..d0afb26c2e0f 100644
> --- a/tools/lib/bpf/bpf.c
> +++ b/tools/lib/bpf/bpf.c
> @@ -54,7 +54,7 @@ static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>   }
>   
>   int bpf_create_map(enum bpf_map_type map_type, int key_size,
> -		   int value_size, int max_entries)
> +		   int value_size, int max_entries, __u32 map_flags)
>   {
>   	union bpf_attr attr;
>   
> @@ -64,6 +64,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
>   	attr.key_size = key_size;
>   	attr.value_size = value_size;
>   	attr.max_entries = max_entries;
> +	attr.map_flags = map_flags;
>   
>   	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
>   }
> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
> index 61130170a6ad..7fcdce16fd62 100644
> --- a/tools/lib/bpf/bpf.h
> +++ b/tools/lib/bpf/bpf.h
> @@ -24,7 +24,7 @@
>   #include <linux/bpf.h>
>   
>   int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
> -		   int max_entries);
> +		   int max_entries, __u32 map_flags);
>   
>   /* Recommend log buffer size */
>   #define BPF_LOG_BUF_SIZE 65536
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 2e974593f3e8..84e6b35da4bd 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -854,7 +854,8 @@ bpf_object__create_maps(struct bpf_object *obj)
>   		*pfd = bpf_create_map(def->type,
>   				      def->key_size,
>   				      def->value_size,
> -				      def->max_entries);
> +				      def->max_entries,
> +				      0);
>   		if (*pfd < 0) {
>   			size_t j;
>   			int err = *pfd;
