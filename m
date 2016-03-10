From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH V3 1/3] net: adjust napi_consume_skb to handle
 none-NAPI callers
Date: Thu, 10 Mar 2016 20:21:55 +0300
Message-ID: <56E1AD33.3020507@cogentembedded.com>
References: <20160310145803.22901.24734.stgit@firesoul>
 <20160310145911.22901.28762.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34850 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbcCJRV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:21:59 -0500
Received: by mail-lb0-f169.google.com with SMTP id bc4so121585284lbc.2
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 09:21:59 -0800 (PST)
In-Reply-To: <20160310145911.22901.28762.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/10/2016 05:59 PM, Jesper Dangaard Brouer wrote:

> Some drivers reuse/share code paths that free SKBs between NAPI
> and none-NAPI calls. Adjust napi_consume_skb to handle this
> use-case.
>
> Before, calls from netpoll (w/ IRQs disabled) was handled and
> indicated with a budget zero indication.  Use the same zero
> indication to handle calls not originating from NAPI/softirq.
> Simply handled by using dev_consume_skb_any().
>
> This adds an extra branch+call for the netpoll case (checking
> in_irq() + irqs_disabled()), but that is okay as this is a slowpath.
>
> Suggested-by: Alexander Duyck <aduyck@mirantis.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   net/core/skbuff.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 7af7ec635d90..bc62baa54ceb 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -801,9 +801,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
>   	if (unlikely(!skb))
>   		return;
>
> -	/* if budget is 0 assume netpoll w/ IRQs disabled */
> +	/* Zero budget indicate none-NAPI context called us, like netpoll */

    Non-NAPI?

[...]

MBR, Sergei
