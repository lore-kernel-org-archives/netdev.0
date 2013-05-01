From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] filter: fix va_list build error
Date: Wed, 01 May 2013 23:04:16 +0200
Message-ID: <51818350.6040600@redhat.com>
References: <1367439848-10854-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756740Ab3EAVEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 17:04:23 -0400
In-Reply-To: <1367439848-10854-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2013 10:24 PM, Xi Wang wrote:
> This patch fixes the following build error.
>
> In file included from include/linux/filter.h:52:0,
>                   from arch/arm/net/bpf_jit_32.c:14:
> include/linux/printk.h:54:2: error: unknown type name =E2=80=98va_lis=
t=E2=80=99
> include/linux/printk.h:105:21: error: unknown type name =E2=80=98va_l=
ist=E2=80=99
> include/linux/printk.h:108:30: error: unknown type name =E2=80=98va_l=
ist=E2=80=99
>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>   include/linux/filter.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index d1248f4..c050dcc 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -48,6 +48,7 @@ extern int sk_chk_filter(struct sock_filter *filter=
, unsigned int flen);
>   extern int sk_get_filter(struct sock *sk, struct sock_filter __user=
 *filter, unsigned len);
>
>   #ifdef CONFIG_BPF_JIT
> +#include <stdarg.h>
>   #include <linux/linkage.h>
>   #include <linux/printk.h>

That's a bit weird. Xi, maybe in a follow-up some time later, could
you move the GCC-internal stdarg.h rather into linux/printk.h, since
that's where the problem is coming from? Imho, it might be better off
there, no?
