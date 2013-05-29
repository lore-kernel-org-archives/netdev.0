From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Thu, 30 May 2013 01:43:39 +0400
Message-ID: <51A6768B.5050603@cogentembedded.com>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:58455 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935203Ab3E2Vni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 17:43:38 -0400
Received: by mail-la0-f45.google.com with SMTP id ec20so9246611lab.18
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 14:43:36 -0700 (PDT)
In-Reply-To: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/30/2013 01:09 AM, Davidlohr Bueso wrote:

> Use the already defined macro to pass the function return address.
>
> Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
> ---
>   net/core/skbuff.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index af9185d..0d06850 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -116,22 +116,22 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
>    *	Keep out of line to prevent kernel bloat.
>    *	__builtin_return_address is not used because it is not always reliable.
>    */
> -static void skb_panic(struct sk_buff *skb, unsigned int sz, void *addr,
> +static void skb_panic(struct sk_buff *skb, unsigned int sz, unsigned long addr,
>   		      const char msg[])
>   {
> -	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
> +	pr_emerg("%s: text:0x%lx len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",

     Why not "text:%#lx" as already used in this string? It's equivalent 
to "0x%lx".

WBR, Sergei
