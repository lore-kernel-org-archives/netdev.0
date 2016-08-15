From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 1/2] tools lib bpf: suppress useless include
Date: Mon, 15 Aug 2016 11:20:39 +0800
Message-ID: <57B13507.7040601@huawei.com>
References: <1471090643-22403-1-git-send-email-eric@regit.org>
 <1471090643-22403-2-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:50435 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbcHODVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 23:21:44 -0400
In-Reply-To: <1471090643-22403-2-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/8/13 20:17, Eric Leblond wrote:
> The include of err.h is not explicitely needed in exported
> functions and it was causing include conflict with some existing
> code due to redefining some macros.
>
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>   tools/lib/bpf/libbpf.c | 1 +
>   tools/lib/bpf/libbpf.h | 1 -
>   2 files changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index b699aea..7872ff6 100644
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
> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index dd7a513..a6c5cde 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -23,7 +23,6 @@
>   
>   #include <stdio.h>
>   #include <stdbool.h>
> -#include <linux/err.h>
>   

Functions declared in this header require PTR_ERR
to decode error number. Logically speaking, this
header depends linux/err.h, so this include is
required. If not, there must have another way for
caller to decode error numbers.

I know the problem you try to solve. Please have a look at thread

https://lkml.org/lkml/2015/12/17/20

At that time I think we should create a wrapper in libbpf.h like this:

#ifdef USE_LINUX_ERR
#include <linux/err.h>
#endif
...
int libbpf_ptr_err(void *ptr);
...

It is acceptable but ugly. Can you find a better method?

Thank you.

>   enum libbpf_errno {
>   	__LIBBPF_ERRNO__START = 4000,
