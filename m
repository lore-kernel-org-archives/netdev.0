From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net] 6lowpan: add missing pskb_may_pull() check
Date: Thu, 10 May 2012 15:30:59 +0200
Message-ID: <1336656659.12504.153.camel@edumazet-glaptop>
References: <1336656163-19382-1-git-send-email-y>
	 <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51049 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022Ab2EJNbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 09:31:05 -0400
Received: by eeit10 with SMTP id t10so515727eei.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 06:31:03 -0700 (PDT)
In-Reply-To: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 17:22 +0400, alex.bluesman.smirnov@gmail.com
wrote:
> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> 
> Add pskb_may_pull() call when fetching u8 from skb.
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  net/ieee802154/6lowpan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 32eb417..0ab3efe 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -295,6 +295,8 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
>  {
>  	u8 ret;
>  
> +	BUG_ON(!pskb_may_pull(skb, 1));
> +
>  	ret = skb->data[0];
>  	skb_pull(skb, 1);
>  

No, you cant do that.

pskb_may_pull() can fail, and you crash your machine instead of graceful
error reporting.
