From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 1/8] tools lib bpf: add error functions
Date: Mon, 17 Oct 2016 09:47:14 +0800
Message-ID: <58042DA2.30901@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-2-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161016211834.11732-2-eric@regit.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/10/17 5:18, Eric Leblond wrote:
> The include of err.h is not explicitely needed in exported
> functions and it was causing include conflict with some existing
> code due to redefining some macros.
>
> To fix this, let's have error handling functions provided by the
> library. Furthermore this will allow user to have an homogeneous
> API.
>
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>   tools/lib/bpf/libbpf.c | 11 +++++++++++
>   tools/lib/bpf/libbpf.h |  4 +++-
>   2 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index b699aea..90932f1 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -31,6 +31,7 @@
>   #include <linux/kernel.h>
>   #include <linux/bpf.h>
>   #include <linux/list.h>
> +#include <linux/err.h>
>   #include <libelf.h>
>   #include <gelf.h>
>   
> @@ -1447,3 +1448,13 @@ bpf_object__find_map_by_name(struct bpf_object *obj, const char *name)
>   	}
>   	return NULL;
>   }
> +
> +bool bpf__is_error(const void *ptr)

Please use libbpf_is_error(), like libbpf_set_print. We use '__' because 
we want
to use the OO concept. This utility is not OO.

> +{
> +	return IS_ERR(ptr);
> +}
> +
> +long bpf__get_error(const void *ptr)

Same, please call it libbpf_get_error().

Thank you.
