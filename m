From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: ipv4: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 05:14:57 -0700
Message-ID: <1371730497.3252.400.camel@edumazet-glaptop>
References: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Zhao Hongjiang <zhaohongjiang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:62167 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757435Ab3FTMPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 08:15:02 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so3934204eaj.3
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 05:15:01 -0700 (PDT)
In-Reply-To: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 18:49 +0800, Zhao Hongjiang wrote:
> for NUL terminated string, need alway set '\0' in the end.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
> ---
>  net/ipv4/tcp_cong.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 019c238..3280234 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -170,7 +170,7 @@ void tcp_get_default_congestion_control(char *name)
>  
>  	rcu_read_lock();
>  	ca = list_entry(tcp_cong_list.next, struct tcp_congestion_ops, list);
> -	strncpy(name, ca->name, TCP_CA_NAME_MAX);
> +	strlcpy(name, ca->name, sizeof(name));
>  	rcu_read_unlock();
>  }
>  

You are quite mistaken.

How did you test this patch exactly ?
