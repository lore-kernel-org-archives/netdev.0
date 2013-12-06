From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] tipc: add link_kfree_skbuff helper function
Date: Thu, 05 Dec 2013 22:44:27 -0800
Message-ID: <1386312267.30495.247.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
	 <1386311022-11176-2-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:65095 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333Ab3LFGo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:44:29 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so490701pdi.19
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 22:44:29 -0800 (PST)
In-Reply-To: <1386311022-11176-2-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 14:23 +0800, Wang Weidong wrote:
> replaces some chunks of code that kfree the sk_buff.
> This is just code simplification, no functional changes.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/tipc/link.c | 58 +++++++++++++++++++--------------------------------------
>  1 file changed, 19 insertions(+), 39 deletions(-)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 69cd9bf..1c27d7b 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -100,6 +100,17 @@ static unsigned int align(unsigned int i)
>  	return (i + 3) & ~3u;
>  }
>  
> +static void link_kfree_skbuff(struct sk_buff *buf)
> +{
> +	struct sk_buff *next;
> +
> +	while (buf) {
> +		next = buf->next;
> +		kfree_skb(buf);
> +		buf = next;
> +	}
> +}
> +

Oh well, this looks like kfree_skb_list() to me.
