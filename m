From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] unix: convert printks to pr_<level>
Date: Fri, 06 Dec 2013 10:22:46 +0100
Message-ID: <52A19766.5030308@redhat.com>
References: <52A16A19.60001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ebiederm@xmission.com, gaofeng@cn.fujitsu.com,
	jacob.e.keller@intel.com, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab3LFJW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 04:22:57 -0500
In-Reply-To: <52A16A19.60001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 07:09 AM, Wang Weidong wrote:
> use pr_<level> instead of printk(LEVEL)
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/unix/af_unix.c |   10 ++++++----
>   1 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4155ed3..ca98e61 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -80,6 +80,9 @@
>    *		  with BSD names.
>    */
>
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +#define DEBUG
> +

Why do you define DEBUG here ?

>   #include <linux/module.h>
>   #include <linux/kernel.h>
>   #include <linux/signal.h>
> @@ -366,7 +369,7 @@ static void unix_sock_destructor(struct sock *sk)
>   	WARN_ON(!sk_unhashed(sk));
>   	WARN_ON(sk->sk_socket);
>   	if (!sock_flag(sk, SOCK_DEAD)) {
> -		printk(KERN_INFO "Attempt to release alive unix socket: %p\n", sk);
> +		pr_info("Attempt to release alive unix socket: %p\n", sk);
>   		return;
>   	}
>
> @@ -378,7 +381,7 @@ static void unix_sock_destructor(struct sock *sk)
>   	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>   	local_bh_enable();
>   #ifdef UNIX_REFCNT_DEBUG
> -	printk(KERN_DEBUG "UNIX %p is destroyed, %ld are still alive.\n", sk,
> +	pr_debug("UNIX %p is destroyed, %ld are still alive.\n", sk,
>   		atomic_long_read(&unix_nr_socks));
>   #endif
>   }
> @@ -2434,8 +2437,7 @@ static int __init af_unix_init(void)
>
>   	rc = proto_register(&unix_proto, 1);
>   	if (rc != 0) {
> -		printk(KERN_CRIT "%s: Cannot create unix_sock SLAB cache!\n",
> -		       __func__);
> +		pr_crit("%s: Cannot create unix_sock SLAB cache!\n", __func__);
>   		goto out;
>   	}
>
>
