From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: create skb_panic() to let caller specify panic
Date: Sat, 09 Feb 2013 21:11:01 -0800
Message-ID: <1360473061.26127.1.camel@joe-AO722>
References: <1360471749-6177-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54094 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750725Ab3BJFLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2013 00:11:03 -0500
In-Reply-To: <1360471749-6177-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-09 at 21:49 -0700, Jean Sacren wrote:
> Combine skb_over_panic() and skb_under_panic() into skb_panic() and let
> the caller specify whether it is skb_over_panic or skb_under_panic.
[]
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
[]
> @@ -104,48 +104,28 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
[]
> -static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
> +static void skb_panic(struct sk_buff *skb, unsigned int size, void *addr,
> +		      const char panic[])
>  {
> -	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
> -		 __func__, here, skb->len, sz, skb->head, skb->data,
> +	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx "
> +		 "end:%#lx dev:%s\n",

Trivia:

Don't split the format across multiple lines please.
