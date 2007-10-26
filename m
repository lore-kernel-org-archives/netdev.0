From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Fri, 26 Oct 2007 17:20:25 -0600
Message-ID: <m1zly5wjie.fsf@ebiederm.dsl.xmission.com>
References: <20071026230807.GE30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34234 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbXJZXUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 19:20:55 -0400
In-Reply-To: <20071026230807.GE30533@stusta.de> (Adrian Bunk's message of
	"Sat, 27 Oct 2007 01:08:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@kernel.org> writes:

> This patch fixes the following build error with CONFIG_SYSCTL=n:
>
> <--  snip  -->
>
> ...
> ERROR: "sysctl_rmem_max" [fs/dlm/dlm.ko] undefined!
> ERROR: "sysctl_wmem_max" [drivers/net/rrunner.ko] undefined!
> ERROR: "sysctl_rmem_max" [drivers/net/rrunner.ko] undefined!
> make[2]: *** [__modpost] Error 1

I was going to ask if allowing drivers to increase rmem_max
is something that we want to do.  Apparently the road runner
driver has been doing this since the 2.6.12-rc1 when the
git repository starts so this probably isn't a latent bug.

So removing unnecessary #ifdef sounds good to me.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>



> <--  snip  -->
>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> ---
> 22ea6cd56e4fa844b0b1bbab2542f09eb6c9a5ab 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index febbcbc..ee1cc4f 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2004,7 +2004,5 @@ EXPORT_SYMBOL(sock_wmalloc);
>  EXPORT_SYMBOL(sock_i_uid);
>  EXPORT_SYMBOL(sock_i_ino);
>  EXPORT_SYMBOL(sysctl_optmem_max);
> -#ifdef CONFIG_SYSCTL
>  EXPORT_SYMBOL(sysctl_rmem_max);
>  EXPORT_SYMBOL(sysctl_wmem_max);
> -#endif
