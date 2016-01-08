From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netlink: fix null pointer dereference on nlk->groups
Date: Fri, 8 Jan 2016 22:43:22 +0300
Message-ID: <5690115A.4070405@cogentembedded.com>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>, davem@davemloft.net,
	herbert@gondor.apana.org.au, daniel@iogearbox.net, tgraf@suug.ch,
	pablo@netfilter.org, chamaken@gmail.com, nicolas.dichtel@6wind.com,
	fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35165 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444AbcAHTn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:43:26 -0500
Received: by mail-lb0-f175.google.com with SMTP id bc4so229366867lbc.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 11:43:26 -0800 (PST)
In-Reply-To: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/08/2016 08:46 AM, Baozeng Ding wrote:

> If groups is not 0 and nlk->groups is NULL, it will not return
> immediately and cause a null pointer dereference later.
>
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
> ---
>   net/netlink/af_netlink.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..38efde0 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
[...]
> @@ -1576,14 +1577,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>   		}
>   	}
>
> -	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
> +	if (nlk->groups == NULL)

    '!nlk->groups' is preferred in the networking code.

[...]

MBR, Sergei
