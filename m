From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH IPROUTE2] ss: Add support for sk_meminfo_backlog
Date: Thu, 07 Jun 2012 06:20:44 +0200
Message-ID: <1339042844.26966.75.camel@edumazet-glaptop>
References: <1339024292-4361-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43448 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932978Ab2FGEUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 00:20:49 -0400
Received: by eaak11 with SMTP id k11so44947eaa.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 21:20:48 -0700 (PDT)
In-Reply-To: <1339024292-4361-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 16:11 -0700, Vijay Subramanian wrote:
> This adds the ability to print the backlog length of sockets that is provided by
> recent Linux kernels since commit (d594e987c6 sock_diag: add
> SK_MEMINFO_BACKLOG).
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  include/linux/sock_diag.h |    1 +
>  misc/ss.c                 |    5 +++--
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
> index 39e4b1c..ac9db19 100644
> --- a/include/linux/sock_diag.h
> +++ b/include/linux/sock_diag.h
> @@ -18,6 +18,7 @@ enum {
>  	SK_MEMINFO_FWD_ALLOC,
>  	SK_MEMINFO_WMEM_QUEUED,
>  	SK_MEMINFO_OPTMEM,
> +	SK_MEMINFO_BACKLOG,
>  
>  	SK_MEMINFO_VARS,
>  };
> diff --git a/misc/ss.c b/misc/ss.c
> index cf529ef..ea14e2b 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1338,14 +1338,15 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
>  
>  	if (tb[INET_DIAG_SKMEMINFO]) {
>  		const __u32 *skmeminfo =  RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
> -		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u)",
> +		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u,bl%u)",
>  			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
>  			skmeminfo[SK_MEMINFO_RCVBUF],
>  			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
>  			skmeminfo[SK_MEMINFO_SNDBUF],
>  			skmeminfo[SK_MEMINFO_FWD_ALLOC],
>  			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
> -			skmeminfo[SK_MEMINFO_OPTMEM]);
> +			skmeminfo[SK_MEMINFO_OPTMEM],
> +			skmeminfo[SK_MEMINFO_BACKLOG]);
>  	}else if (tb[INET_DIAG_MEMINFO]) {
>  		const struct inet_diag_meminfo *minfo
>  			= RTA_DATA(tb[INET_DIAG_MEMINFO]);


This is not the right way to handle this.

I already have a patch and was waiting the appropriate time to submit
it.

Thanks
