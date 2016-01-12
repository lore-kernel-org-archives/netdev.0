From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH v3] netlink: fix null pointer dereference on nlk->groups
Date: Tue, 12 Jan 2016 14:15:54 +0300
Message-ID: <CAOJe8K10a=MLyZwFCYvstP+KG3bND09RjbXVZDR5gWfFxCvMcg@mail.gmail.com>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
	<1452597043-4298-1-git-send-email-sploving1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33651 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcALLPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 06:15:54 -0500
Received: by mail-qk0-f196.google.com with SMTP id n135so26832038qka.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 03:15:54 -0800 (PST)
In-Reply-To: <1452597043-4298-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/16, Baozeng Ding <sploving1@gmail.com> wrote:
> If groups is not 0 and nlk->groups is NULL, it will not return
> immediately and cause a null pointer dereference later.
>
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
> ---
> The v3 version adds WARN_ON, suggested by David Miller. Thanks for
> David's feedback.

But can you explain how can we get to this situation?

> ---
>  net/netlink/af_netlink.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..f93d579 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1576,7 +1576,10 @@ static int netlink_bind(struct socket *sock, struct
> sockaddr *addr,
>  		}
>  	}
>
> -	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
> +	if (WARN_ON(!nlk->groups))
> +		return 0;
> +
> +	if (!groups && !(u32)nlk->groups[0])
>  		return 0;
>
>  	netlink_table_grab();
> --
> 1.9.1
>
>
